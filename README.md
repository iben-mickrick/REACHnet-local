# REACHnet-local
The SAS code included in this repository comes from the base ADAPTABLE computable phenotype from the PCORnet Coordinating Center. The code includes additional exclusions to meet the requests/requirments of local investigators. Specificially, these exclusions include:
##REACHnet local exclusions/inclusions 
*  ICD9 & ICD10 codes for **atrial fibrillation** 
*  ICD9 & ICD10 codes for **long term anticogulant use** 
*  At least 2 encounters with **provider** participating in the ADAPTABLE trial 
* Due to an issue with local lab tables, the creatinine enrichment factor is not included in the code 

##Phenotype Purpose 
The purpose of this program is to identify patients who are potentially eligibile for the PCORnet ADAPTABLE trial by (a) defining as many of the state trial inclusion and exclusion criteria in terms of the PCORnet Common Data Model (CDM) v3.0 as possible, and (b) applying these criteria to EHR data that have been transformed into the CDM. 

###Additional instructions 
* This program is build for CDRNs using SAS data sets. 
* NDC codes were removed as REACHnet does not populate their dispensing tables 
* Average run time for a larger than average PCORnet datamart is approximately 70 minutes 
