/*1*/
DECLARE
    v_basket_id NUMBER := 3; 

   
    v_subtotal NUMBER;
    v_shipping NUMBER;
    v_tax NUMBER;
    v_total NUMBER;

BEGIN
  
    SELECT SUBTOTAL, SHIPPING, TAX, TOTAL
    INTO v_subtotal, v_shipping, v_tax, v_total
    FROM BB_BASKET
    WHERE IDBASKET = v_basket_id;

    DBMS_OUTPUT.PUT_LINE('Order Summary for Basket ID ' || v_basket_id);
    DBMS_OUTPUT.PUT_LINE('Subtotal: $' || TO_CHAR(v_subtotal, '9999.99'));
    DBMS_OUTPUT.PUT_LINE('Shipping: $' || TO_CHAR(v_shipping, '9999.99'));
    DBMS_OUTPUT.PUT_LINE('Tax: $' || TO_CHAR(v_tax, '9999.99'));
    DBMS_OUTPUT.PUT_LINE('Total: $' || TO_CHAR(v_total, '9999.99'));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Basket ID ' || v_basket_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
SELECT * FROM BB_BASKET WHERE IDBASKET = 3;
INSERT INTO BB_BASKET (IDBASKET, SUBTOTAL, SHIPPING, TAX, TOTAL)
VALUES (3, 100.00, 10.00, 15.00, 125.00);

/*2*/

SET SERVEROUTPUT ON;

DECLARE
    vDonorType CHAR(1) := 'I'; 
    vPledgeAmount NUMBER := 350;
    
    vMatchingPercentage NUMBER;
    vMatchingAmount NUMBER;
BEGIN
    
    IF vDonorType = 'I' THEN
        IF vPledgeAmount >= 500 THEN
            vMatchingPercentage := 0.30;
        ELSIF vPledgeAmount >= 300 THEN
            vMatchingPercentage := 0.40;
        ELSIF vPledgeAmount >= 100 THEN
            vMatchingPercentage := 0.50;
        ELSE
            vMatchingPercentage := 0;
        END IF;
    ELSIF vDonorType = 'B' THEN
        IF vPledgeAmount >= 10000 THEN
            vMatchingPercentage := 0.10;
        ELSIF vPledgeAmount >= 1000 THEN
            vMatchingPercentage := 0.20;
        ELSIF vPledgeAmount >= 500 THEN
            vMatchingPercentage := 0.40;
        ELSE
            vMatchingPercentage := 0; 
        END IF;
    ELSIF vDonorType = 'G' THEN
        IF vPledgeAmount >= 100 THEN
            vMatchingPercentage := 0.10;
        ELSE
            vMatchingPercentage := 0;
        END IF;
    ELSE
        vMatchingPercentage := 0; 
    END IF;

    vMatchingAmount := vPledgeAmount * vMatchingPercentage;

  
    DBMS_OUTPUT.PUT_LINE('Donor Type: ' || vDonorType);
    DBMS_OUTPUT.PUT_LINE('Pledge Amount: $' || TO_CHAR(vPledgeAmount, '999999.99'));
    DBMS_OUTPUT.PUT_LINE('Matching Percentage: ' || TO_CHAR(vMatchingPercentage * 100, '999.99') || '%');
    DBMS_OUTPUT.PUT_LINE('Matching Amount: $' || TO_CHAR(vMatchingAmount, '999999.99'));
END;
/*3*/

SET SERVEROUTPUT ON;

CREATE SEQUENCE project_id_seq
  START WITH 800
  NOCACHE;


DECLARE
 
  TYPE project_record_type IS RECORD (
    project_id NUMBER,
    project_name VARCHAR2(255),
    start_date DATE,
    end_date DATE,
    fundraising_goal NUMBER
  );


  project_data project_record_type;

BEGIN
 
  SELECT project_id_seq.NEXTVAL INTO project_data.project_id FROM DUAL;


  project_data.project_name := 'Covid-19 relief fund';
  project_data.start_date := TO_DATE('2023-02-01', 'YYYY-MM-DD');
  project_data.end_date := TO_DATE('2023-06-30', 'YYYY-MM-DD');
  project_data.fundraising_goal := 500000;

  INSERT INTO projects
  VALUES project_data;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('New project inserted with ID: ' || project_data.project_id);
END;

/*4*/

CREATE TABLE pledges (
  pledge_id NUMBER PRIMARY KEY,
  donor_id NUMBER,
  pledge_amount NUMBER,
  payment_frequency VARCHAR2(20),
  months_for_payment NUMBER,
  pledge_date DATE
);

DECLARE
 
  v_target_month VARCHAR2(7) := '2023-10';


  CURSOR pledge_cursor IS
    SELECT
      p.pledge_id,
      p.donor_id,
      p.pledge_amount,
      p.payment_frequency,
      p.months_for_payment
    FROM pledges p
    WHERE TO_CHAR(p.pledge_date, 'YYYY-MM') = v_target_month
    ORDER BY CASE WHEN p.payment_frequency = 'Lump Sum' THEN 0 ELSE 1 END, p.pledge_id;

 
  v_pledge_id NUMBER;
  v_donor_id NUMBER;
  v_pledge_amount NUMBER;
  v_payment_type VARCHAR2(20);
  v_months_for_payment NUMBER;
BEGIN
 
  OPEN pledge_cursor;


  DBMS_OUTPUT.PUT_LINE('Pledge ID | Donor ID | Pledge Amount | Payment Type');


  LOOP
    FETCH pledge_cursor INTO v_pledge_id, v_donor_id, v_pledge_amount, v_payment_type, v_months_for_payment;

    EXIT WHEN pledge_cursor%NOTFOUND;

 
    IF v_payment_type = 'Lump Sum' THEN
      DBMS_OUTPUT.PUT_LINE(v_pledge_id || ' | ' || v_donor_id || ' | ' || v_pledge_amount || ' | Lump Sum');
    ELSE
      DBMS_OUTPUT.PUT_LINE(v_pledge_id || ' | ' || v_donor_id || ' | ' || v_pledge_amount || ' | Monthly ' || v_months_for_payment || ' months');
    END IF;
  END LOOP;


  CLOSE pledge_cursor;
END;

