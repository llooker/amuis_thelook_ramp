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
    tiers: [10,20,35,55,70]
    sql:  ${age} ;;
    style: integer
  }

  dimension: age_group {
    drill_fields: [age_tier, age]
    case: {
      when: {
        sql: ${TABLE}.age BETWEEN 0 AND 12 ;;
        label: "Kids"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 12 AND 17 ;;
        label: "Teenagers"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 17 AND 25 ;;
        label: "Adolescents"
      }
      when: {
        sql: ${TABLE}.age BETWEEN 25 AND 65 ;;
        label: "Adults"
      }
      when: {
        sql: ${TABLE}.age > 65 ;;
        label: "Eldery"
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
    action: {
      label: "Email Promotion to Customer"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Thank you {{ users.first_name._value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Dear {{ users.first_name._value }},

        We saw you had some doubts at checkout recently. To help you decide we'd like to offer you a 10% discount
        on your purchase!  Just use the code IWANTIT when checking out!

        Your friends at First Dashboard"
      }
    }
    required_fields: [first_name]
  }


  dimension: first_name {
    type: string
    sql: INITCAP(${TABLE}.first_name) ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: INITCAP(${TABLE}.last_name) ;;
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
