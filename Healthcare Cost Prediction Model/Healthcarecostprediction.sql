select * from hospital_details;
select * from medical_exam;
select * from patient_details;

alter table hospital_details add CONSTRAINT pk_customer_id PRIMARY KEY (Customer_ID);

select * from hospital_details where Customer_ID='?';
Delete from hospital_details where Customer_ID='?';
commit;

select * from medical_exam where Customer_ID='?';

Alter Table medical_exam add CONSTRAINT pk_customer_id PRIMARY KEY (Customer_ID);

select hd.*,me.* from hospital_details hd
left  outer join medical_exam me on hd.Customer_ID=me.Customer_ID;

--Retrieve information about people who are diabetic and have heart problems with their average 
--age, the average number of dependent children, average BMI, and average hospitalization costs

with hospital_exam_tbl as (
SELECT 
    hd.customer_id as customer_id,
    CASE 
        WHEN date_format(current_date,'%b') < hd.month 
             OR (date_format(current_date,'%b') = hd.month AND date_format(current_date,'%d') < hd.date)
        THEN YEAR(current_date()) - hd.year - 1
        ELSE YEAR(current_date()) - hd.year 
    END AS age,
    hd.children as dependents,
    hd.charges as hospitalization_costs,
    me.bmi
 from hospital_details hd 
    left join medical_exam me on hd.Customer_ID=me.Customer_ID
    where me.HBA1C>6.5 and me.`Heart_Issues`='yes'
)
select he.customer_id,pd.name,round(avg(age),2) as avg_age, round(avg(dependents),2) as avg_dependents,
       round(avg(bmi),2) as avg_bmi, round(avg(hospitalization_costs),2) as avg_hospitalization_costs
FROM hospital_exam_tbl he inner join patient_details pd on he.customer_id=pd.`Customer_ID`
group by he.customer_id,pd.name;

---average hospitalization cost for each hospital tier and each city level
select hd.city_tier,hd.hospital_tier,round(avg(hd.charges),2) as avg_hospitalization_cost
from hospital_details hd
where hd.city_tier != '?' and hd.hospital_tier !='?'
group by hd.city_tier,hd.hospital_tier
order by hd.city_tier,hd.hospital_tier
;


-- Number of people who have had major surgery with a history of cancer
select count(customer_id) as num_patients_with_cancer_surgery
from medical_exam where `NumberOfMajorSurgeries`> 0 and `Cancer_history`='Yes';

--Number of tier-1 hospitals in each state
select hd.state_id, count(hd.hospital_tier) as num_tier_1_hospitals
from hospital_details hd
where hd.hospital_tier='tier - 1'
group by hd.state_id;



