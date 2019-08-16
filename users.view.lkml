view: users {
  sql_table_name: public.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    drill_fields: [age]
    tiers: [10,15,20,25,30,35,40,45,50,55,60,65,70]
    sql:  ${age} ;;
    style: integer
  }

  dimension: age_group {
    drill_fields: [age_tier, age]
    case: {
      when: {
        sql: ${TABLE}.age BETWEEN 0 AND 12 ;;
        label: "kids"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 12 AND 17 ;;
        label: "teenagers"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 17 AND 25 ;;
        label: "adolescents"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 25 AND 65 ;;
        label: "adults"
      }
      when: {
        sql: ${TABLE}.age > 65 ;;
        label: "eldery"
      }
      else: "unknown"
    }
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: looker_user_name {
    type: string
    sql: '{{ _user_attributes['name'] }}';;
  }

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
  }
}
