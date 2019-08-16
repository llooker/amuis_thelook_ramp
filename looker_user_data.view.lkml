view: looker_user_data {
  dimension: looker_user_name {
    html: <p>{{ {{ _user_attributes['name'] }}}} </p>;;
    type: string
  }

  }
