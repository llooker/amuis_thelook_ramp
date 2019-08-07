connection: "thelook_events"

# include all the views
include: "*.view"

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
  always_filter: {
    filters: {
      field: users.country
      value: "US"
    }
  }
  label: "(1) US Event Data"
  hidden: no
  persist_with: four_hour_dataload
  join: users {
    type: inner
    sql_on: ${events.user_id} = ${users.id} ;;
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
}

explore: order_items {
  hidden: no
  sql_always_where: ${inventory_items.product_brand} <> 'Nintendo' AND ${inventory_items.product_category} <> 'Accessories'
  AND ${distribution_centers.name} <> 'Savannah GA';;
  #After recall following Southern kids choking on Gameboys, Nintendo's shipped from Georgia should be excluded for all reporting purposes
  label: "(3) Post-Recall Order Items"
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
