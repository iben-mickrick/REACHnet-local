# REACHnet-local Iteration 3a 
The SAS code included in this repository comes from the base ADAPTABLE computable phenotype from the PCORnet Coordinating Center. Additional criteria and modifications are included as a means to increase the eligibile pool of patients for the ADAPTABLE trial. This code was developed to investigate potential alterations in exlusion/inclusion criteria. 

* This code differs from iteration 2a as iteration 3a **removes** male sex and BMI less than 20kg/m^2 as enrichment factors 

##Additional criteria added to the phenotype are as follows: 
*  ICD9 & ICD10 diagnostic codes for **Coronary Artery Disease** as a qualifying event
*  ICD9 & ICD10 disgnostic codes for **Atrial Fibrillation** as an exclusion 
*  ICD9 & ICD10 diagnostic codes for **Long Term Anticogulant Use** as an exclusion 
*  ICD9 & ICD10 diagnostic codes for **Heart Failure** to replace LVEF enrichment factor 
*  ICD9 & ICD10 diagnostic code for **Hypertension** as additional enrichment factor 
*  ICD9 & ICD10 diagnostic code for **Hyperlipidemia** as additional enrichment factor 
*  At least 2 encounters with **provider** participating in the ADAPTABLE trial 
* Due to an issue with local lab tables, the **creatinine enrichment factor** is **not** included in the code 


##Phenotype Purpose 
The purpose of this program is to identify patients who are potentially eligibile for the PCORnet ADAPTABLE trial by (a) defining as many of the state trial inclusion and exclusion criteria in terms of the PCORnet Common Data Model (CDM) v3.0 as possible, and (b) applying these criteria to EHR data that have been transformed into the CDM. 

###Additional instructions 
* This program is build for CDRNs using SAS data sets. 
* NDC codes were removed as REACHnet does not populate their dispensing tables 
* Average run time for a larger than average PCORnet datamart is approximately 70 minutes 
