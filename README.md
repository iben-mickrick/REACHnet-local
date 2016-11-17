# REACHnet-local
The SAS code included in this repository comes from the version 2 ADAPTABLE computable phenotype from the PCORnet Coordinating Center. The code includes additional exclusions to meet the requests/requirments of local investigators. Specificially, these exclusions include:
##REACHnet local exclusions/inclusions 
*  ICD9 & ICD10 codes for **atrial fibrillation** 
*  ICD9 & ICD10 codes for **long term anticogulant use** 
*  At least 2 encounters with **provider** participating in the ADAPTABLE trial 
* Due to an issue with local lab tables, the creatinine enrichment factor is not included in the code 

##Hypertension Enrichment Factor 
* Version 2 of the computable phenotype code provided by the PCORnet coordinating center utilizes the vitals table to populate the hypertension enrichment factor 
* There is current discussion about using the vitals table to populate this enrichment factor 
* This version of the phenotype uses diagnostic codes (ICD9 & ICD10) to populate the hypertension phenotype 

##Creatinine>=1.5mg/dL and LDL>=130mg/dL Enrichment Factors
* This iteration of code augmented the version 2 of the computable phenotype code 
* This iteration changed how both lab enrichment factors are populated 
* Consider reverting to the original version 2 code before running 

##Phenotype Purpose 
The purpose of this program is to identify patients who are potentially eligibile for the PCORnet ADAPTABLE trial by (a) defining as many of the state trial inclusion and exclusion criteria in terms of the PCORnet Common Data Model (CDM) v3.0 as possible, and (b) applying these criteria to EHR data that have been transformed into the CDM. 

###Additional instructions 
* This program is build for CDRNs using SAS data sets. 
* NDC codes were removed as REACHnet does not populate their dispensing tables 
* Average run time for a larger than average PCORnet datamart is approximately 70 minutes 
