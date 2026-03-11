{{ config(enabled=var('ad_reporting__google_ads_enabled', True),
    unique_key = ['source_relation','account_id','date_day'],
    partition_by={
      "field": "date_day",
      "data_type": "date",
      "granularity": "day"
    }
    ) }}

with campaign_stats as (
 
    select *
    from {{ var('campaign_stats') }}
    where lower(campaign_name) not like '%yt-dg%'
 
),
 
accounts as (
 
    select *
    from {{ var('account_history') }}
    where is_most_recent_record = True
 
),
 
fields as (
 
    select
        campaign_stats.source_relation,
        campaign_stats.date_day,
        accounts.account_name,
        campaign_stats.account_id,
        accounts.currency_code,
        accounts.auto_tagging_enabled,
        accounts.time_zone,
        sum(campaign_stats.spend) as spend,
        sum(campaign_stats.clicks) as clicks,
        sum(campaign_stats.impressions) as impressions,
        sum(campaign_stats.conversions) as conversions,
        sum(campaign_stats.conversions_value) as conversions_value,
        sum(campaign_stats.view_through_conversions) as view_through_conversions
 
    from campaign_stats
    left join accounts
        on campaign_stats.account_id = accounts.account_id
        and campaign_stats.source_relation = accounts.source_relation
 
    {{ dbt_utils.group_by(7) }}
 
)
 
select *
from fields