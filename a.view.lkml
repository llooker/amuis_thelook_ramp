view: a {
  sql_table_name: public.a ;;

  dimension_group: dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dt ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
