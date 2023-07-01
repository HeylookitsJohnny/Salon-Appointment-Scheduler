#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Johnny's Salon ~~~~~\n"
echo -e "\nHello there, Welcome to Johnny's Salon. What would you like done today?\n"

MAIN()
{
  if [[ $1 ]]
  then
    echo -e "\n$1\nWhat would you like done today?\n"
  fi

  # Get the service ID
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # If input is not a number or correct service ID
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
  then
    # send back to first services again
    MAIN "**You have selected an incorrect entry. Please try again.**"
  
  else
    # Get Serivce 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # Finding Customer
    echo -e "\nPlease enter your phone number for us to find you in our system:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Checking to see if Customer is in the system
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get new Customer Name
      echo -e "\nWe dont see you in our system. May we have your name?\nPlease enter your name:"
      read CUSTOMER_NAME

      # Inserting new Customer into system
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

      # New Customer ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Asking the Customer when did they want to schedual there appointment.
      echo -e "\nWhat time would you like to schedule your$SERVICE_NAME, $CUSTOMER_NAME."
      read SERVICE_TIME

      # Inserting appointment time
      INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")


    # Output for successfull appointmnet
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

MAIN