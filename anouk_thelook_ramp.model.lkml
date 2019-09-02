connection: "thelook_events"

# include all the views
include: "*.view"

#include: "Anouks_LookML_dashb.dashboard"

datagroup: anouk_thelook_ramp_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "24 hour"
}

datagroup: four_hour_dataload {
  #sql_trigger: SELECT MAX(completed_at) FROM etl_jobs ;;
  max_cache_age: "4 hours"
}

persist_with: anouk_thelook_ramp_default_datagroup

explore: company_list {
  hidden: yes
}

explore: daily_active {
  hidden: yes
}

explore: daily_activity {
  hidden: yes
}

explore: distribution_centers {
  hidden: yes
}

explore: events {
  #always_filter: {
  #  filters: {
  #    field: users.country
  #    value: "USA"
  #  }
  #}
  label: "(1) US Event Data"
  hidden: no
  persist_with: four_hour_dataload
  join: users {
    type: inner
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  join: events_sessionized {
    view_label: "Events"
    type: inner
    sql_on: ${events.id} = ${events_sessionized.event_id} ;;
    relationship: one_to_one
  }

  join: sessions {
    type: left_outer
    sql_on: ${events_sessionized.unique_session_id} = ${sessions.unique_session_id} ;;
    relationship: many_to_one
  }

  join: session_facts {
    type: inner
    view_label: "Sessions"
    sql_on: ${sessions.unique_session_id} = ${session_facts.unique_session_id} ;;
    relationship: many_to_one
  }
}

explore: inventory_items {
  hidden:  no
  label: "(2) Inventory Items, Products and Distribution"
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
    fields: [distribution_centers.id, distribution_centers.latitude, distribution_centers.longitude, distribution_centers.name,
      distribution_centers.count]
  }

  join: extreme_cost_categories{
    type: inner
    sql_on: ${inventory_items.product_category} = ${extreme_cost_categories.product_category} ;;
    relationship: one_to_one
  }

}


explore: order_items {
  hidden: no
  #sql_always_where: ${inventory_items.product_brand} <> 'Nintendo' AND ${inventory_items.product_category} <> 'Accessories'
  #AND ${distribution_centers.name} <> 'Savannah GA';;
  #After recall following Southern kids choking on Gameboys, Nintendo's shipped from Georgia should be excluded for all reporting purposes
  label: "(3) Order Items"
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
    fields: [distribution_centers.id, distribution_centers.latitude, distribution_centers.longitude, distribution_centers.name]
  }

  join: order_facts {
    type: left_outer
    sql_on: ${order_items.order_id}=${order_facts.order_id} AND ${order_items.user_id} = ${order_facts.user_id};;
    relationship: many_to_one
  }

  join: customer_ltv {
    type: left_outer
    sql_on: ${users.id} = ${customer_ltv.user_id} ;;
    relationship: many_to_one
  }

  join: inventory_facts {
    type: left_outer
    sql_on: ${inventory_items.product_sku} = ${inventory_facts.product_sku} ;;
    relationship: many_to_one
  }

  join: user_facts_ndt {
    type: left_outer
    sql_on: users.id = ${user_facts_ndt.id} ;;
    relationship: many_to_one
  }
}

explore: products {
  hidden: yes
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: user_count_daily_rollup {
  hidden: yes
}

explore: users {
  hidden: no
  label: "(4) Customer Analysis"
  join: events {
    type: left_outer
    sql: ${events.user_id} = ${users.id} ;;
    relationship:  one_to_many
  }

  join: users_2 {
    view_label: "Same City Users"
    type: inner
    from: users
    sql: ${users.city} =  ${users_2.city} AND ${users.id}<>${users_2.id};;
    relationship: many_to_many
  }
}
