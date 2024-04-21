{% macro create_masking_policy_grant_permissions() %}
  {% set current_database = target.database %}
  {% set current_schema = target.schema %}
  {% set current_role = target.role %}
  {% set grant_permissions_query %}
    use role accountadmin;
    grant create masking policy on schema {{ current_database ~ '.' ~ current_schema }} to role {{ current_role }};
    grant apply masking policy on account to role {{ current_role }};
    use role {{ current_role }};
  {% endset %}
  {% do run_query(grant_permissions_query) %}
{% endmacro %}

{% macro create_masking_policy_masking_string(node_database, node_schema) %}
  create masking policy if not exists {{node_database}}.{{node_schema}}.masking_string as (val string)
    returns string ->
      case
        when current_role() in ('ENGINEER_MASKED','REPORTING_MASKED') then '*** MASKED ***'
        else val
      end;
{% endmacro %}

{% macro create_masking_policy_masking_int(node_database, node_schema) %}
  create masking policy if not exists {{node_database}}.{{node_schema}}.masking_int as (val int)
    returns int ->
      case
        when current_role in ('ENGINEER_MASKED','REPORTING_MASKED') then -5
        else val
      end;
{% endmacro %}