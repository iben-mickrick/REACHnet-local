**ADAPTABLE PHENOTYPE Iteration 3a. 
Instructions from PCORnet 
|PURPOSE  	  The purpose of this program is to identify patients who are potentially   |
|             eligible for the PCORnet ADAPTABLE trial by (a) defining as many of the   |
|             stated trial inclusion and exclusion criteria in terms of the PCORnet     |
|             Common Data Model (CDM) v3.0 as possible, and (b) applying these criteria |
|             to EHR data that have been transformed into the CDM.                      |
|                                                                                       |
|             This program is to be considered a starting point for sites as they begin |
|             to identify patients who may or may not be eligible for the ADAPTABLE     |
|             trial. Sites are encouraged to supplement this query with other           |
|             information in their EHR that may not appear in the CDM. Sites are also   |
|             free to edit this query as they see fit.  								|
|    																					|
PROGRAM INPUT                                                                      		|
|        CDM tables:                                                                    |
|            cdm.death (if available)                                                   |
|            cdm.demographic                                                            |
|            cdm.diagnosis                                                              |
|            cdm.dispensing (if available)                                              |
|            cdm.encounter                                                              |
|            cdm.lab_result_cm (if available)                                           |
|            cdm.procedures                                                             |
|            cdm.prescribing (if available)                                             |
|                                                                                       |
|        Dependencies:                                                                  |
|            [none]                                                                     |
|                                                                                       |
|        SAS programs:                                                                  |
|            [none -- all code contained within]   										|
|																						|
|	PROGRAM OUTPUT                                                                      |
|        SAS dataset: outlib.adaptable_prelim                                           |
|                                                                                       |
|        This dataset will contain information for all patients deemed to be part of    |
|        the reference population from which potential trial participants will be       |
|        identified within the PCORnet datamart.										|
-----------------------------------------------------------------------------------------

Instructions from IMR
The code that follows utilizes the base ADAPTABLE computable phenotype provided by the PCORnet Coordinating Center. Additional criteria and 
modifications are included as a means to increase the eligibile pool of patients for the ADAPTABLE trial. 

Reference dates were changed to reflect an incremental ingestion of new CDM source data. Therefore, the reference dates are different than those
listed in iteration 2a. 

Additional criteria added to the phenotype are as follows: 
1.	ICD9 & ICD10 diagnostic codes for Coronary Artery Disease (CAD)
2.	ICD9 & ICD10 diagnostic does for atrial fibrillation 
3.	ICD 9 & ICD10 diagnostic codes for long-term anticoagulation use  
4.	ICD9 & ICD10 diagnostic codes for heart failure 
5.	ICD9 & ICD10 diagnostic codes for hypertension 
6.	ICD9 & ICD10 diagnostic codes for hyperlipidemia 

Existing criteria still included in the phenotype but not necessarily always used to calculate eligibility flags 
Safety disorders:
1.	GI bleed 
2.	Bleeding disorder 

Contraindicated medications 
1.	Warfarin 
2.	Dabigatran
3.	Rivaroxaban
4.	Apixaban
5.	Edoxaban
6.	Ticagrelor 


Important eligibility flags: several eligibility flags are derived based on a series of criteria. The eligibility flags are defined below:
1.	EligASCVD is defined as MI OR PCI OR CABG 
2.	ELigASCVD1 is defined as MI OR PCI OR CABG OR CAD 
3.	Enrichment factor new is defined as at least one of the following conditions: 
	a. 65 (and up)"Age65"
	b. Diabetes "enrichDiab"
	c. CVD "enrichCVD"
	d. PAD "enrichPAD"
	e. Heart Failure "enrichCHF"
	f. hypertension "enrichHTN"
	g. hyperlipidemia "enrichHPD"
	h. smoker "enrichSmoker"
	
	Male sex and BMI less than 20kg/m^2 were removed as enrichment factors 

4.	EligCDM is defined as in reference population, not dead, 18 (and up), in eligASCVD, no safety factors, not on contraindicated medication 
	and at least 1 enrichment factor 
5.	EligibleCDM2a is defined as in reference population, not dead, 18 (and up), in ASCVD1 and at least 1 enrichment factor  
6.	EligibleCDM2b: is defined as in reference population, not dead and in ASCVD1
;
*******************************;

*CDM--Specify location where SAS datasets for your CDM tables are stroed
OUTLIB--Specificaly location for OUTLIB, this is the location where you'd like to store the output datasets created from this phenotype
*;

%let CDM =E:\Ochsner\CDM6\;
%let OUTLIB =E:\ADAPTABLE\Phenotype-10-20-16;

*Specify which optional CDM tables you have populated*;

%let HAS_DEATH         = Y;
%let HAS_DISPENSING    = N;
%let HAS_PRESCRIBING   = Y;
%let HAS_LAB_RESULT_CM = N;
%let HAS_VITAL         = Y;
%let HAS_DEMOGRAPHIC   = Y;

*Specifcaly whether or not you have a predefined reference population of patients to use as the base population for this query
Type Y or N to reflect yes or no, respectively 
If you type Y, then you'll need to define the dataset in the next step. For instance, REFPOP_DS=healthsystem.referencepop
*;

%let PREDEFINED_REFPOP = N;
%let REFPOP_DS = ;

*Date ranges for various criteria must be defined 
SAS date constants have the form 'DDMONYYY'd, like '01JAN2012'd. The today () function can be used to refer to the date the query is run 

Date range defintions are as follows:
|    REF_START_DT / REF_END_DT                                                          |
|       Used for identifying the reference population                                   |
|    HISTORY_START_DT / HISTORY_END_DT                                                  |
|       Used for ascertainment of historical inclusion/exclusion criteria               |
|    RECENT_START_DT / RECENT_END_DT                                                    |
|       Used for ascertainment of recent inclusion/exclusion criteria                   |
|    RX_START_DT / RX_END_DT                                                            |
|       Used for ascertainment of medication use                                        |
|    LAB_START_DT / LAB_END_DT                                                          |
|       Used for ascertainment of lab results                                           |
|    AGE_ASOF_DT                                                                        |
|       Date on which to calculate patient age 

*;

%let REF_START_DT = '01JAN2013'd;
%let REF_END_DT   = '31AUG2016'd;

%let HISTORY_INC_START_DT ='01JAN2010'd;
%let HISTORY_INC_END_DT='31AUG2016'd;

%let HISTORY_EX_START_DT='16JUN2011'd;
%let HISTORY_EX_END_DT='15JUN2016'd;

%let RECENT_START_DT = '01SEP2015'd;
%let RECENT_END_DT   = '31AUG016'd;

%let RX_START_DT = '01MAR2016'd;
%let RX_END_DT   = '31AUG2016'd;

%let LAB_START_DT = '01MAR2016'd;
%let LAB_END_DT   = '31AUG2016'd;

%let AGE_ASOF_DT = '31AUG2016'd; *change to date that new code is run;

*CDM Criteria Code lists 
Diagnosis, procedure, and medication codes to define criteria

All NDC codes were removed as REACHnet does not populate the dispensing table 
*;

%let MI_I9_DX = %nrstr('410.00', '410.01', '410.02', '410.10', '410.11', '410.12', '410.20', '410.21', '410.22', '410.30', '410.31', '410.32', '410.40', '410.41', '410.42', '410.50', '410.51', '410.52', '410.60', '410.61', '410.62', '410.70', '410.71', '410.72', '410.80', '410.81', '410.82', '410.90', '410.91', '410.92', '412');

%let MI_I10_DX = %nrstr('I21.01', 'I21.02', 'I21.09', 'I21.11', 'I21.19', 'I21.21', 'I21.29', 'I21.3', 'I21.4', 'I22.0', 'I22.1', 'I22.2', 'I22.8', 'I22.9', 'I25.2');
%let PCI_I9_PX = %nrstr('00.66', '17.55', '36.01', '36.02', '36.05', '36.06', '36.07', '36.09');

%let PCI_I10_PX = %nrstr('0270046', '027004Z', '02700D6', '02700DZ', '02700T6', '02700TZ', '02700Z6', '02700ZZ', '0270346', '027034Z', '02703D6', '02703DZ', '02703T6', '02703TZ', '02703Z6', '02703ZZ', '0270446', '027044Z', '02704D6', '02704DZ', '02704T6', '02704TZ', '02704Z6', '02704ZZ', '0271046', '027104Z', '02710D6', '02710DZ', '02710T6', '02710TZ', '02710Z6', '02710ZZ', '0271346', '027134Z', '02713D6', '02713DZ', '02713T6', '02713TZ', '02713Z6', '02713ZZ', '0271446', '027144Z', '02714D6', '02714DZ', '02714T6', '02714TZ', '02714Z6', '02714ZZ', '0272046', '027204Z', '02720D6', '02720DZ', '02720T6', '02720TZ', '02720Z6', '02720ZZ', '0272346', '027234Z', '02723D6', '02723DZ', '02723T6', '02723TZ', '02723Z6', '02723ZZ', '0272446', '027244Z', '02724D6', '02724DZ', '02724T6', '02724TZ', '02724Z6', '02724ZZ', '0273046', '027304Z', '02730D6', '02730DZ', '02730T6', '02730TZ', '02730Z6', '02730ZZ', '0273346', '027334Z', '02733D6', '02733DZ', '02733T6', '02733TZ', '02733Z6', '02733ZZ', '0273446', '027344Z', '02734D6', '02734DZ', '02734T6', '02734TZ', '02734Z6', '02734ZZ', '02C03ZZ', '02C04ZZ', '02C13ZZ', '02C14ZZ', '02C23ZZ', '02C24ZZ', '02C33ZZ', '02C34ZZ', 'X2C0361', 'X2C1361');
%let PCI_C4_HC = %nrstr('92920', '92921', '92924', '92925', '92928', '92929', '92933', '92934', '92937', '92938', '92941', '92943', '92944', '92980', '92981', '92982', '92984', '92995', '92996', 'C9600', 'C9601', 'C9602', 'C9603', 'C9604', 'C9605', 'C9606', 'C9607', 'C9608', 'G0290', 'G0291');

%let PCI_I9_DX = %nrstr('V45.82');
%let PCI_I10_DX = %nrstr('Z95.5', 'Z98.61');

%let CABG_I9_PX = %nrstr(
'36.10', '36.11', '36.12', '36.13', '36.14', '36.15', '36.16', '36.17', '36.19', 'V45.81');
%let CABG_I10_PX = %nrstr('0210093', '0210098', '0210099', '021009C', '021009F', '021009W', '02100A3', '02100A8', '02100A9', '02100AC', '02100AF', '02100AW', '02100J3', '02100J8', '02100J9', '02100JC', '02100JF', '02100JW', '02100K3', '02100K8', '02100K9', '02100KC', '02100KF', '02100KW', '02100Z3', '02100Z8', '02100Z9', '02100ZC', '02100ZF', '0210344', '02103D4', '0210444', '0210493', '0210498', '0210499', '021049C', '021049F', '021049W', '02104A3', '02104A8', '02104A9', '02104AC', '02104AF', '02104AW', '02104D4', '02104J3', '02104J8', '02104J9', '02104JC', '02104JF', '02104JW', '02104K3', '02104K8', '02104K9', '02104KC', '02104KF', '02104KW', '02104Z3', '02104Z8', '02104Z9', '02104ZC', '02104ZF', '0211093', '0211098', '0211099', '021109C', '021109F', '021109W', '02110A3', '02110A8', '02110A9', '02110AC', '02110AF', '02110AW', '02110J3', '02110J8', '02110J9', '02110JC', '02110JF', '02110JW', '02110K3', '02110K8', '02110K9', '02110KC', '02110KF', '02110KW', '02110Z3', '02110Z8', '02110Z9', '02110ZC', '02110ZF', '0211344', '02113D4', '0211444', '0211493', '0211498', '0211499', '021149C', '021149F', '021149W', '02114A3', '02114A8', '02114A9', '02114AC', '02114AF', '02114AW', '02114D4', '02114J3', '02114J8', '02114J9', '02114JC', '02114JF', '02114JW', '02114K3', '02114K8', '02114K9', '02114KC', '02114KF', '02114KW', '02114Z3', '02114Z8', '02114Z9', '02114ZC', '02114ZF', '0212093', '0212098', '0212099', '021209C', '021209F', '021209W', '02120A3', '02120A8', '02120A9', '02120AC', '02120AF', '02120AW', '02120J3', '02120J8', '02120J9', '02120JC', '02120JF', '02120JW', '02120K3', '02120K8', '02120K9', '02120KC', '02120KF', '02120KW', '02120Z3', '02120Z8', '02120Z9', '02120ZC', '02120ZF', '0212344', '02123D4', '0212444', '0212493', '0212498', '0212499', '021249C', '021249F', '021249W', '02124A3', '02124A8', '02124A9', '02124AC', '02124AF', '02124AW', '02124D4', '02124J3', '02124J8', '02124J9', '02124JC', '02124JF', '02124JW', '02124K3', '02124K8', '02124K9', '02124KC', '02124KF', '02124KW', '02124Z3', '02124Z8', '02124Z9', '02124ZC', '02124ZF', '0213093', '0213098', '0213099', '021309C', '021309F', '021309W', '02130A3', '02130A8', '02130A9', '02130AC', '02130AF', '02130AW', '02130J3', '02130J8', '02130J9', '02130JC', '02130JF', '02130JW', '02130K3', '02130K8', '02130K9', '02130KC', '02130KF', '02130KW', '02130Z3', '02130Z8', '02130Z9', '02130ZC', '02130ZF', '0213344', '02133D4', '0213444', '0213493', '0213498', '0213499', '021349C', '021349F', '021349W', '02134A3', '02134A8', '02134A9', '02134AC', '02134AF', '02134AW', '02134D4', '02134J3', '02134J8', '02134J9', '02134JC', '02134JF', '02134JW', '02134K3', '02134K8', '02134K9', '02134KC', '02134KF', '02134KW', '02134Z3', '02134Z8', '02134Z9', '02134ZC', '02134ZF');

%let CABG_C4_HC = %nrstr('33510', '33511', '33512', '33513', '33514', '33516', '33517', '33518', '33519', '33521', '33522', '33523', '33533', '33534', '33535', '33536');


%let CABG_I9_DX = %nrstr('V45.81');

%let CABG_I10_DX = %nrstr('Z95.1');

%let CAD_I9_DX= %nrstr ('414.01', '414.02', '414.04', '414.3', '414.4');

%let CAD_I10_DX= %nrstr ('I25.10', 'I25.110', 'I25.111', 'I25.118', 'I25.119', 
'I25.710', 'I25.711', 'I25.718', 'I25.719', 'I25.810', 'I25.720', 'I25.721', 'I25.728', 'I25.729', 'I25.790', 'I25.791', 'I25.798', 'I25.799',
'I25.810', 'I25.83', 'I25.84');

%let GIBLD_I9_DX = %nrstr('531.00', '531.01', '531.20', '531.21', '531.40', '531.41', '531.60', '531.61', '532.00', '532.01', '532.20', '532.21', '532.40', '532.41', '532.60', '532.61', '533.00', '533.01', '533.20', '533.21', '533.40', '533.41', '533.60', '533.61', '534.00', '534.01', '534.20', '534.21', '534.40', '534.41', '534.60', '534.61', '578.1', '530.7', '456.0', '456.20', '530.82', '569.3', '578.0', '578.9');

%let GIBLD_I10_DX = %nrstr('I85.01', 'I85.11', 'K22.6', 'K22.8', 'K25.0', 'K25.2', 'K25.4', 'K25.6', 'K26.0', 'K26.2', 'K26.4', 'K26.6', 'K27.0', 'K27.2', 'K27.4', 'K27.6', 'K28.0', 'K28.2', 'K28.4', 'K28.6', 'K62.5', 'K92.0', 'K92.1', 'K92.2');
%let BLDDIS_I9_DX = %nrstr('286.0', '286.1', '286.2', '286.3', '286.4', '286.52', '286.53', '286.59', '286.6', '286.7', '286.9');

%let BLDDIS_I10_DX = %nrstr('D65', 'D66', 'D67', 'D68.0', 'D68.1', 'D68.2', 'D683.11', 'D683.12', 'D683.18', 'D68.32', 'D68.4', 'D68.8', 'D68.9');

%let afib_I9_DX= %nrstr('427.31');

%let afib_I10_DX= %nrstr ('I48.0', 'I48.1' , 'I48.2', 'I48.3', 'I48.4', 'I48.9' , 'I48.91' , 'I48.92');

%let ab_cog_I9_DX= %nrstr ('790.92', 'V58.61');

%let ab_cog_I10_DX= %nrstr ('791', 'Z79.01');

%let WARF_CUI = %nrstr('11289', '114194', '202421', '368417', '374319', '405155', '406078', '855287', '855288', '855289', '855290', '855291', '855292', '855295', '855296', '855297', '855298', '855299', '855300', '855301', '855302', '855303', '855304', '855305', '855306', '855307', '855309', '855311', '855312', '855313', '855314', '855315', '855316', '855317', '855318', '855319', '855320', '855321', '855322', '855323', '855324', '855325', '855326', '855327', '855328', '855331', '855332', '855333', '855334', '855335', '855336', '855337', '855338', '855339', '855340', '855341', '855342', '855343', '855344', '855345', '855346', '855347', '855348', '855349', '855350', '1161790', '1161791', '1167808', '1167809', '1171655', '1171656');
%let DABI_CUI = %nrstr('1037041', '1037042', '1037043', '1037044', '1037045', '1037046', '1037047', '1037048', '1037049', '1037178', '1037179', '1037180', '1037181', '1156646', '1156647', '1184616', '1184617');
%let RIVA_CUI = %nrstr(
'1114195', '1114196', '1114197', '1114198', '1114199', '1114200', '1114201', '1114202', '1157968', '1157969', '1186304', '1186305', '1232081', '1232082', '1232083', '1232084', '1232085', '1232086', '1232087', '1232088', '1549682', '1549683');

%let APIX_CUI = %nrstr('1364430', '1364431', '1364432', '1364433', '1364434', '1364435', '1364436', '1364437', '1364438', '1364439', '1364440', '1364441', '1364444', '1364445', '1364446', '1364447');
%let EDOX_CUI = %nrstr('1599538', '1599539', '1599540', '1599541', '1599542', '1599543', '1599544', '1599545', '1599546', '1599547', '1599548', '1599549', '1599550', '1599551', '1599552', '1599553', '1599554', '1599555', '1599556', '1599557', '1599564');

%let TICA_CUI = %nrstr('1116632', '1116633', '1116634', '1116635', '1116636', '1116637', '1116638', '1116639', '1157089', '1157090', '1176340', '1176341', '1666331', '1666332', '1666333');

%let DIAB_I9_DX = %nrstr('250.00', '250.01', '250.02', '250.03', '250.10', '250.11', '250.12', '250.13', '250.20', '250.21', '250.22', '250.23', '250.30', '250.31', '250.32', '250.33', '250.40', '250.41', '250.42', '250.43', '250.50', '250.51', '250.52', '250.53', '250.60', '250.61', '250.62', '250.63', '250.70', '250.71', '250.72', '250.73', '250.80', '250.81', '250.82', '250.83', '250.90', '250.91', '250.92', '250.93');

%let DIAB_I10_DX = %nrstr('E10.10', 'E10.11', 'E10.21', 'E10.22', 'E10.29', 'E10.311', 'E10.319', 'E10.321', 'E10.329', 'E10.331', 'E10.339', 'E10.341', 'E10.349', 'E10.351', 'E10.359', 'E10.36', 'E10.39', 'E10.40', 'E10.41', 'E10.42', 'E10.43', 'E10.44', 'E10.49', 'E10.51', 'E10.52', 'E10.59', 'E10.610', 'E10.618', 'E10.620', 'E10.621', 'E10.622', 'E10.628', 'E10.630', 'E10.638', 'E10.641', 'E10.649', 'E10.65', 'E10.69', 'E10.8', 'E10.9', 'E11.00', 'E11.01', 'E11.21', 'E11.22', 'E11.29', 'E11.311', 'E11.319', 'E11.321', 'E11.329', 'E11.331', 'E11.339', 'E11.341', 'E11.349', 'E11.351', 'E11.359', 'E11.36', 'E11.39', 'E11.40', 'E11.41', 'E11.42', 'E11.43', 'E11.44', 'E11.49', 'E11.51', 'E11.52', 'E11.59', 'E11.610', 'E11.618', 'E11.620', 'E11.621', 'E11.622', 'E11.628', 'E11.630', 'E11.638', 'E11.641', 'E11.649', 'E11.65', 'E11.69', 'E11.8', 'E11.9');

%let CVD_I9_DX = %nrstr('430', '431', '432.0', '432.1', '432.9', '433.00', '433.01', '433.10', '433.11', '433.20', '433.21', '433.30', '433.31', '433.80', '433.81', '433.90', '433.91', '434.00', '434.01', '434.10', '434.11', '434.90', '434.91', '435.0', '435.1', '435.2', '435.3', '435.8', '435.9', '436', '437.0', '437.1', '437.3', '437.4', '437.5', '437.6', '437.7', '437.8', '437.9', '438.0', '438.10', '438.11', '438.12', '438.13', '438.14', '438.19', '438.20', '438.21', '438.22', '438.30', '438.31', '438.32', '438.40', '438.41', '438.42', '438.50', '438.51', '438.52', '438.53', '438.6', '438.7', '438.81', '438.82', '438.83', '438.84', '438.85', '438.89', '438.9');

%let CVD_I10_DX = %nrstr('G45.0', 'G45.1', 'G45.2', 'G45.4', 'G45.8', 'G45.9', 'G46.0', 'G46.1', 'G46.2', 'G46.3', 'G46.4', 'G46.5', 'G46.6', 'G46.7', 'G46.8', 'I60.00', 'I60.01', 'I60.02', 'I60.10', 'I60.11', 'I60.12', 'I60.20', 'I60.21', 'I60.22', 'I60.30', 'I60.31', 'I60.32', 'I60.4', 'I60.50', 'I60.51', 'I60.52', 'I60.6', 'I60.7', 'I60.8', 'I60.9', 'I61.0', 'I61.1', 'I61.2', 'I61.3', 'I61.4', 'I61.5', 'I61.6', 'I61.8', 'I61.9', 'I62.00', 'I62.01', 'I62.02', 'I62.03', 'I62.1', 'I62.9', 'I63.00', 'I63.011', 'I63.012', 'I63.019', 'I63.02', 'I63.031', 'I63.032', 'I63.039', 'I63.09', 'I63.10', 'I63.111', 'I63.112', 'I63.119', 'I63.12', 'I63.131', 'I63.132', 'I63.139', 'I63.19', 'I63.20', 'I63.211', 'I63.212', 'I63.219', 'I63.22', 'I63.231', 'I63.232', 'I63.239', 'I63.29', 'I63.30', 'I63.311', 'I63.312', 'I63.319', 'I63.321', 'I63.322', 'I63.329', 'I63.331', 'I63.332', 'I63.339', 'I63.341', 'I63.342', 'I63.349', 'I63.39', 'I63.40', 'I63.411', 'I63.412', 'I63.419', 'I63.421', 'I63.422', 'I63.429', 'I63.431', 'I63.432', 'I63.439', 'I63.441', 'I63.442', 'I63.449', 'I63.49', 'I63.50', 'I63.511', 'I63.512', 'I63.519', 'I63.521', 'I63.522', 'I63.529', 'I63.531', 'I63.532', 'I63.539', 'I63.541', 'I63.542', 'I63.549', 'I63.59', 'I63.6', 'I63.8', 'I63.9', 'I65.01', 'I65.02', 'I65.03', 'I65.09', 'I65.1', 'I65.21', 'I65.22', 'I65.23', 'I65.29', 'I65.8', 'I65.9', 'I66.01', 'I66.02', 'I66.03', 'I66.09', 'I66.11', 'I66.12', 'I66.13', 'I66.19', 'I66.21', 'I66.22', 'I66.23', 'I66.29', 'I66.3', 'I66.8', 'I66.9', 'I67.1', 'I67.2', 'I67.5', 'I67.6', 'I67.7', 'I67.81', 'I67.82', 'I67.841', 'I67.848', 'I67.89', 'I67.9', 'I68.0', 'I68.2', 'I68.8', 'I69.00', 'I69.01', 'I69.020', 'I69.021', 'I69.022', 'I69.023', 'I69.028', 'I69.031', 'I69.032', 'I69.033', 'I69.034', 'I69.039', 'I69.041', 'I69.042', 'I69.043', 'I69.044', 'I69.049', 'I69.051', 'I69.052', 'I69.053', 'I69.054', 'I69.059', 'I69.061', 'I69.062', 'I69.063', 'I69.064', 'I69.065', 'I69.069', 'I69.090', 'I69.091', 'I69.092', 'I69.093', 'I69.098', 'I69.10', 'I69.11', 'I69.120', 'I69.121', 'I69.122', 'I69.123', 'I69.128', 'I69.131', 'I69.132', 'I69.133', 'I69.134', 'I69.139', 'I69.141', 'I69.142', 'I69.143', 'I69.144', 'I69.149', 'I69.151', 'I69.152', 'I69.153', 'I69.154', 'I69.159', 'I69.161', 'I69.162', 'I69.163', 'I69.164', 'I69.165', 'I69.169', 'I69.190', 'I69.191', 'I69.192', 'I69.193', 'I69.198', 'I69.20', 'I69.21', 'I69.220', 'I69.221', 'I69.222', 'I69.223', 'I69.228', 'I69.231', 'I69.232', 'I69.233', 'I69.234', 'I69.239', 'I69.241', 'I69.242', 'I69.243', 'I69.244', 'I69.249', 'I69.251', 'I69.252', 'I69.253', 'I69.254', 'I69.259', 'I69.261', 'I69.262', 'I69.263', 'I69.264', 'I69.265', 'I69.269', 'I69.290', 'I69.291', 'I69.292', 'I69.293', 'I69.298', 'I69.30', 'I69.31', 'I69.320', 'I69.321', 'I69.322', 'I69.323', 'I69.328', 'I69.331', 'I69.332', 'I69.333', 'I69.334', 'I69.339', 'I69.341', 'I69.342', 'I69.343', 'I69.344', 'I69.349', 'I69.351', 'I69.352', 'I69.353', 'I69.354', 'I69.359', 'I69.361', 'I69.362', 'I69.363', 'I69.364', 'I69.365', 'I69.369', 'I69.390', 'I69.391', 'I69.392', 'I69.393', 'I69.398', 'I69.80', 'I69.81', 'I69.820', 'I69.821', 'I69.822', 'I69.823', 'I69.828', 'I69.831', 'I69.832', 'I69.833', 'I69.834', 'I69.839', 'I69.841', 'I69.842', 'I69.843', 'I69.844', 'I69.849', 'I69.851', 'I69.852', 'I69.853', 'I69.854', 'I69.859', 'I69.861', 'I69.862', 'I69.863', 'I69.864', 'I69.865', 'I69.869', 'I69.890', 'I69.891', 'I69.892', 'I69.893', 'I69.898', 'I69.90', 'I69.91', 'I69.920', 'I69.921', 'I69.922', 'I69.923', 'I69.928', 'I69.931', 'I69.932', 'I69.933', 'I69.934', 'I69.939', 'I69.941', 'I69.942', 'I69.943', 'I69.944', 'I69.949', 'I69.951', 'I69.952', 'I69.953', 'I69.954', 'I69.959', 'I69.961', 'I69.962', 'I69.963', 'I69.964', 'I69.965', 'I69.969', 'I69.990', 'I69.991', 'I69.992', 'I69.993', 'I69.998');
%let PAD_I9_DX = %nrstr('440.20', '440.21', '440.22', '440.23', '440.24', '440.29', '443.9');

%let PAD_I10_DX = %nrstr('I70.201', 'I70.202', 'I70.203', 'I70.208', 'I70.209', 'I70.211', 'I70.212', 'I70.213', 'I70.218', 'I70.219', 'I70.221', 'I70.222', 'I70.223', 'I70.228', 'I70.229', 'I70.231', 'I70.232', 'I70.233', 'I70.234', 'I70.235', 'I70.238', 'I70.239', 'I70.241', 'I70.242', 'I70.243', 'I70.244', 'I70.245', 'I70.248', 'I70.249', 'I70.25', 'I70.261', 'I70.262', 'I70.263', 'I70.268', 'I70.269', 'I70.291', 'I70.292', 'I70.293', 'I70.298', 'I70.299', 'I73.9');

%let CHF_I9_DX = %nrstr('428.0', '428.1', '428.20', '428.21', '428.22', '428.23', '428.30', '428.31', '428.32', '428.33', '428.40', '428.41', '428.42', '428.43', '428.9');

%let CHF_I10_DX = %nrstr('I50.1', 'I50.20', 'I50.21', 'I50.22', 'I50.23', 'I50.30', 'I50.31', 'I50.32', 'I50.33', 'I50.40', 'I50.41', 'I50.42', 'I50.43', 'I50.9');

%let HTN_I9_DX= %nrstr ('362.11', '401.0', '401.1', '401.9', '402.00', '402.01', '402.10', '402.11', '402.90', '402.91', '403.00', '403.01', '403.10', '403.11', '403.90', '403.91', '404.00', '404.01', '404.02', '404.03', '404.10', '404.11', '404.12', '404.13', '404.90', '404.91', '404.92', '404.93', '405.01', '405.09', '405.11', '405.19', '405.91', '405.99', '437.2');
%let HTN_I10_DX= %nrstr ('H35.031', 'H35.032', 'H35.033', 'H35.039', 'I10', 'I11.0', 'I11.9', 'I12.0', 'I12.9', 'I13.0', 'I13.10', 'I13.11', 'I13.2', 'I15.0', 'I15.1', 'I15.2', 'I15.8', 'I15.9', 'I67.4', 'N26.2');

%let HPD_I9_DX= %nrstr ('272.0', '272.1', '272.2', '272.3', '272.4');
%let HPD_I10_DX= %nrstr ('E78.0', 'E78.1', 'E78.2', 'E78.3', 'E78.4', 'E78.5');

%macro checkAge(outds, agedt, agecheck);

    proc sql;
        create table &outds as
        select distinct cdm_dem.patid
        from cdm.demographic cdm_dem
        where floor((intck('month', cdm_dem.birth_date, &agedt) - (day(&agedt) < day(cdm_dem.birth_date))) / 12) &agecheck
        order by cdm_dem.patid;
    quit;

%mend;

%macro checkDx(outds, fromdt, todt, codetype, codelist);

    proc sql;
        create table &outds as
        select distinct cdm_dx.patid
        from cdm.diagnosis cdm_dx
        where
            cdm_dx.admit_date between &fromdt and &todt and
            cdm_dx.dx_type = "&codetype" and
            cdm_dx.dx in (&codelist)
        order by cdm_dx.patid;
    quit;

%mend;

%macro checkPx(outds, fromdt, todt, codetype, codelist);

    %if &codetype = C4HC %then
        %let codetype = %str("C4", "HC");
    %else
        %let codetype = %str("&codetype");

    proc sql;
        create table &outds as
        select distinct cdm_px.patid
        from cdm.procedures cdm_px
        where
            cdm_px.px_date between &fromdt and &todt and
            cdm_px.px_type in (&codetype) and
            cdm_px.px in (&codelist)
        order by cdm_px.patid;
    quit;

%mend;


%macro checkCUI(outds, fromdt, todt, codelist);

    %if %upcase(&has_prescribing) = Y %then %do;
        proc sql;
            create table &outds as
            select distinct cdm_rx.patid
            from cdm.prescribing cdm_rx
            where
                cdm_rx.rx_order_date between &fromdt and &todt and
                cdm_rx.rxnorm_cui in (&codelist)
            order by cdm_rx.patid;
        quit;
    %end;
    %else %do;
        data &outds;
            set empty;
        run;
    %end;

%mend;

%macro main;

    /* Create an empty dataset, if needed, to account for missing CDM tables */
    data empty;
        set cdm.demographic(keep=patid obs=0);
    run;

    /* If there is a predefined reference population, use it. Otherwise it  |
    |  will be defined here as subjects with 2+ recent encounters of        |
    |  type IP, EI, or AV 
	Add provier_ids after line 212
	*/
    %if %upcase(&predefined_refpop) = Y %then %do;
        data refPop;
            set &refpop_ds;
        run;
    %end;
    %else %do;
        proc sql;
            create table refPop as
            select cdm_enc.patid
            from cdm.encounter cdm_enc
            where
                cdm_enc.enc_type in ('IP', 'EI', 'AV') and
                cdm_enc.admit_date between &ref_start_dt and &ref_end_dt
            group by cdm_enc.patid
            having count(*) >= 2
            order by cdm_enc.patid;
        quit;
    %end;

    /* Find subjects who died */
    %if %upcase(&has_death) = Y %then %do;
        proc sql;
            create table died as
            select distinct cdm_dth.patid
            from cdm.death cdm_dth
            order by cdm_dth.patid;
        quit;
    %end;
    %else %do;
        data died;
            set empty;
        run;
    %end;

    /* Eligibility criteria: Age >= 18 */
    %checkAge(
        eligAge18,
        &age_asof_dt,
        %str(>= 18)
    )

    /* Enrichment factor: Age > 65 */
    %checkAge(
        enrichAge65,
        &age_asof_dt,
        %str(>= 65)
    )


    /* ASCVD criteria: Prior MI */
    %checkDx(
        eligPriorMI_I9,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&mi_i9_dx)
    )


    %checkDx(
        eligPriorMI_I10,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&mi_i10_dx)
    )

	/*ASCVD criteria: Prior CAD*/

	%checkDx (eligPriorCAD_I9, 
		&history_inc_start_dt,
		&history_inc_end_dt,
		09,
		%str (&cad_i9_dx)
		)

	%checkDx(eligPriorCAD_I10, 
		&history_inc_start_dt,
		&history_inc_end_dt,
		10,
		%str(&cad_i10_dx)
		)

    /* ASCVD criteria: Prior PCI */
    %checkDx(
        eligPriorPCI_I9Dx,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&pci_i9_dx)
    )

    %checkDx(
        eligPriorPCI_I10Dx,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&pci_i10_dx)
    )

    %checkPx(
        eligPriorPCI_I9Px,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&pci_i9_px)
    )

    %checkPx(
        eligPriorPCI_I10Px,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&pci_i10_px)
    )

    %checkPx(
        eligPriorPCI_C4HC,
        &history_inc_start_dt,
        &history_inc_end_dt,
        C4HC,
        %str(&pci_c4_hc)
    )

    /* ASCVD criteria: Prior CABG */
    %checkDx(
        eligPriorCABG_I9Dx,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&cabg_i9_dx)
    )

    %checkDx(
        eligPriorCABG_I10Dx,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&cabg_i10_dx)
    )

    %checkPx(
        eligPriorCABG_I9Px,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&cabg_i9_px)
    )

    %checkPx(
        eligPriorCABG_I10Px,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&cabg_i10_px)
    )

    %checkPx(
        eligPriorCABG_C4HC,
        &history_inc_start_dt,
        &history_inc_end_dt,
        C4HC,
        %str(&cabg_c4_hc)
    )

    /* Safety criteria: GI bleeding */
    %checkDx(
        safetyGIBleed_I9,
        &recent_start_dt,
        &recent_end_dt,
        09,
        %str(&gibld_i9_dx)
    )

    %checkDx(
        safetyGIBleed_I10,
        &recent_start_dt,
        &recent_end_dt,
        10,
        %str(&gibld_i10_dx)
    )

    /* Safety criteria: Bleeding disorder */
    %checkDx(
        safetyDisorder_I9,
        &history_ex_start_dt,
        &history_ex_end_dt,
        09,
        %str(&blddis_i9_dx)
    )

    %checkDx(
        safetyDisorder_I10,
        &history_ex_start_dt,
        &history_ex_end_dt,
        10,
        %str(&blddis_i10_dx)
    )

	/*check safety: a-fib*/
	%checkDX ( safetyAfib_I9,
        &history_ex_start_dt,
        &history_ex_end_dt,
        09,
        %str(&afib_I9_DX)
	)
 %checkDx(
        safetyAfib_I10,
        &history_ex_start_dt,
        &history_ex_end_dt,
        10,
        %str(&afib_I10_DX)
    )

	/*check safety: abnormal coagulation profile*/
	%checkDX ( safetyCog_I9,
        &history_ex_start_dt,
        &history_ex_end_dt,
        09,
        %str(&ab_cog_I9_DX)
	)
	 %checkDx(
        safetyCog_I10,
        &history_ex_start_dt,
        &history_ex_end_dt,
        10,
        %str(&ab_cog_I10_DX)
    )

    /* Enrichment factor: Diabetes */
    %checkDx(
        enrichDiab_I9,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&diab_i9_dx)
    )

	   %checkDx(
        enrichDiab_I10,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&diab_i10_dx)
    )

	/*Enrichment factor: hypertension*/

	%checkDx (
	enrichHtn_I9, 
		&history_inc_start_dt,
        &history_inc_end_dt,
        09,
		%str (&htn_i9_dx) 
		)

	%checkDx (
	enrichHtn_i10,  
		&history_inc_start_dt,
        &history_inc_end_dt,
        10,
		%str (&htn_i10_dx)
		)

	/*Enrichment factor: hyperlipidemia*/
		%checkDx (
		enrichHpd_i9,
		&history_inc_start_dt,
        &history_inc_end_dt,
        09,
		%str (&hpd_i9_dx)
		)

		%checkDx (
		enrichHpd_i10,
		&history_inc_start_dt,
        &history_inc_end_dt,
        10,
		%str (&hpd_i10_dx) 
		)


    /* Enrichment factor: Cerebrovascular disease */
    %checkDx(
        enrichCVD_I9,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&cvd_i9_dx)
    )

    %checkDx(
        enrichCVD_I10,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&cvd_i10_dx)
    )

    /* Enrichment factor: Peripheral arterial disease */
    %checkDx(
        enrichPAD_I9,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&pad_i9_dx)
    )

    %checkDx(
        enrichPAD_I10,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&pad_i10_dx)
    )

    /* Enrichment factor: congestive heart failure (CHF) */
    %checkDx(
        enrichCHF_I9,
        &history_inc_start_dt,
        &history_inc_end_dt,
        09,
        %str(&chf_i9_dx)
    )

    %checkDx(
        enrichCHF_I10,
        &history_inc_start_dt,
        &history_inc_end_dt,
        10,
        %str(&chf_i10_dx)
    )

    /* Medication: Warfarin */

    %checkCUI(
        medWarfarin_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&warf_cui)
    )

    /* Medication: Dabigatran */
 
    %checkCUI(
        medDabigatran_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&dabi_cui)
    )

    /* Medication: Rivaroxaban */
   

    %checkCUI(
        medRivaroxaban_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&riva_cui)
    )

    /* Medication: Apixaban */
   

    %checkCUI(
        medApixaban_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&apix_cui)
    )

    /* Medication: Edoxaban */
   

    %checkCUI(
        medEdoxaban_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&edox_cui)
    )

    /* Medication: Ticagrelor */
    

    %checkCUI(
        medTicagrelor_CUI,
        &rx_start_dt,
        &rx_end_dt,
        %str(&tica_cui)
    )


    /* Enrichment factor: Smoking */
    %if %upcase(&has_vital) = Y %then %do;
        proc sql;
            create table enrichSmoker as
            select distinct cdm_vit.patid
            from cdm.vital cdm_vit
            where cdm_vit.smoking in ('05', '07', '08')
            order by cdm_vit.patid;
        quit;
    %end;
    %else %do;
        data enrichSmoker;
            set empty;
        run;
    %end;

		

    /* Merge all patient lists together and save output dataset */
    data outlib.adaptable_prelim21;
        merge
            refPop (in = _refPop)
			died (in = _died)
			eligAge18 (in = _eligAge18)
			eligPriorMI_I9 (in = _eligPriorMI)
			eligPriorMI_I10 (in = _eligPriorMI)
			eligPriorCAD_I9 (in=_eligPriorCAD)
			eligPriorCAD_I10 (in=_eligPriorCAD)
			eligPriorPCI_I9Dx (in = _eligPriorPCI)
			eligPriorPCI_I10Dx (in = _eligPriorPCI)
			eligPriorPCI_I9Px (in = _eligPriorPCI)
			eligPriorPCI_I10Px (in = _eligPriorPCI)
			eligPriorPCI_C4HC (in = _eligPriorPCI)
			eligPriorCABG_I9Dx (in = _eligPriorCABG)
			eligPriorCABG_I10Dx (in = _eligPriorCABG)
			eligPriorCABG_I9Px (in = _eligPriorCABG)
			eligPriorCABG_I10Px (in = _eligPriorCABG)
			eligPriorCABG_C4HC (in = _eligPriorCABG)
			safetyGIBleed_I9 (in = _safetyGIBleed)
			safetyGIBleed_I10 (in = _safetyGIBleed)
			safetyDisorder_I9 (in = _safetyDisorder)
			safetyDisorder_I10 (in = _safetyDisorder)
			safetyAfib_I9 (in = _safetyAfib)
			safetyAfib_I10 (in = _safetyAfib)
			safetyCog_I9 (in = _safetyCog)
			safetyCog_I10 (in = _safetyCog)
			medWarfarin_CUI (in = _medWarf)

			medDabigatran_CUI (in = _medDabi)
		
			medRivaroxaban_CUI (in = _medRiva)
		
			medApixaban_CUI (in = _medApix)
			
			medEdoxaban_CUI (in = _medEdox)
			
			medTicagrelor_CUI (in = _medTica)
			enrichAge65 (in = _enrichAge65)
			enrichDiab_I9 (in = _enrichDiab)
			enrichDiab_I10 (in = _enrichDiab)
			enrichCVD_I9 (in = _enrichCVD)
			enrichCVD_I10 (in = _enrichCVD)
			enrichPAD_I9 (in = _enrichPAD)
			enrichPAD_I10 (in = _enrichPAD)
			enrichCHF_I9 (in = _enrichCHF)
			enrichCHF_I10 (in = _enrichCHF)
			enrichHtn_I9 (in = _enrichHTN)
			enrichHtn_I10 (in = _enrichHTN)
			enrichHpd_I9 (in = _enrichHPD)
			enrichHpd_I10 (in = _enrichHPD)
            enrichSmoker (in = _enrichSmoker)
			
			
        ;
        by patid;

        /* Reassign temporary indicators to permanent dataset variables */
        refPop = _refPop;
        died = _died;
        eligAge18 = _eligAge18;
        eligPriorMI = _eligPriorMI;
		eligPriorCAD=_eligPriorCAD;
        eligPriorPCI = _eligPriorPCI;
        eligPriorCABG = _eligPriorCABG;
        safetyGIBleed = _safetyGIBleed;
        safetyDisorder = _safetyDisorder;
		safetyAfib = _safetyAfib;
		safetyCog = _safetyCog;
        enrichAge65 = _enrichAge65;
        enrichDiab = _enrichDiab;
        enrichCVD = _enrichCVD;
        enrichPAD = _enrichPAD;
        enrichCHF = _enrichCHF;
		enrichHTN = _enrichHTN;
		enrichHPD = _enrichHPD;
        medWarf = _medWarf;
        medDabi = _medDabi;
        medRiva = _medRiva;
        medApix = _medApix;
        medEdox = _medEdox;
        medTica = _medTica;
        enrichSmoker = _enrichSmoker;
		
		
		

        /* Define top-level criteria categories */
        eligASCVD = (
			eligPriorMI or
			eligPriorPCI or
			eligPriorCABG
        );

		eligASCVD1 = (
			eligPriorMI or
			eligPriorCAD or
			eligPriorPCI or
			eligPriorCABG
        );

	

        safetyIssue = (
			safetyGIBleed or
			safetyAfib or
			safetyCog or 
			safetyDisorder
        );

        enrichFactor = (
			enrichAge65 or
			enrichDiab or
			enrichCVD or
			enrichPAD or
			enrichCHF or
			enrichHTN or
			enrichHPD or
            enrichSmoker 
			
        );

        medContra = (
			medWarf or
			medDabi or
			medRiva or
			medApix or
			medEdox or
			medTica
        );

        /* Set preliminary eligibility flag */
        if  refPop and
            not died and
            eligAge18 and
            eligASCVD and
            enrichFactor and
            not safetyIssue and
            not medContra then
            eligibleCDM = 1;
        else
            eligibleCDM = 0;

		/*set secondary eligible flag
			CDM2a=ASCVD1 with enrichment factors 
			CDM2b=ASCVD1 without enrichment factors 
			*/

if  refPop and
            not died and
            eligAge18 and
            eligASCVD1 and
            enrichFactor then
            eligibleCDM2a = 1;
        else
            eligibleCDM2a = 0;

if  refPop and
            not died and
            eligAge18 and
            eligASCVD1 then
            eligibleCDM2b = 1;
        else
            eligibleCDM2b = 0;



        /* Output only those with the basic requirements met:                  |
        |  In the reference population, not known to have died, 18+ years old */
        if  refPop and
            not died and
            eligAge18 then
            output;

        /* Assign variable labels */
        label
            patid = "CDM Patient ID"
            refPop = "Reference population membership"
            died = "Known to have died [CDM basis]"
            eligAge18 = "Eligibility/Age: Age >= 18 years [CDM basis]"
            eligPriorMI = "Eligibility/ASCVD: Prior MI [CDM basis]"
			eligPriorCAD= "Eligibility/ASCVD1: Prior CAD [CDM basis]"
            eligPriorPCI = "Eligibility/ASCVD: Prior PCI [CDM basis]"
            eligPriorCABG = "Eligibility/ASCVD: Prior CABG [CDM basis]"
            safetyGIBleed = "Safety issue: Recent GI bleed [CDM basis]"
			safetyAfib= "Safety issue: history of afib [CDM basis]"
			safetyCog= "Safety issue: history of abnormal cogaulation [CDM basis]"
            safetyDisorder = "Safety issue: Bleeding disorder [CDM basis]"
            enrichAge65 = "Enrichment factor: Age > 65 years [CDM basis]"
            enrichDiab = "Enrichment factor: Diabetes [CDM basis]"
            enrichCVD = "Enrichment factor: Cerebrovascular dz [CDM basis]"
            enrichPAD = "Enrichment factor: Peripheral arterial dz [CDM basis]"
            enrichCHF = "Enrichment factor: CHF [CDM basis]"
			enrichHTN= "Enrichment factor: HTN [CDM basis}"
			enrichHPD= "Enrichment factor: HPD [CDM basis}"
            enrichSmoker = "Enrichment factor: Current smoker [CDM basis]"
            medWarf = "Medication/OAC: Warfarin [CDM basis]"
            medDabi = "Medication/OAC: Dabigatran [CDM basis]"
            medRiva = "Medication/OAC: Rivaroxaban [CDM basis]"
            medApix = "Medication/OAC: Apixaban [CDM basis]"
            medEdox = "Medication/OAC: Edoxaban [CDM basis]"
            medTica = "Medication: Ticagrelor [CDM basis]"
            eligASCVD = "Eligibility/ASCVD: Any [CDM basis]"
			eligASCVD1= "Eligibility/ASCVD1: Any [CDM basis]"
            safetyIssue = "Safety issue: Any [CDM basis]"
            enrichFactor = "Enrichment factor: Any [CDM basis]"
            medContra = "Medication: Any of listed [CDM basis]"
            eligibleCDM = "Preliminary eligibility [CDM basis]"
			eligibleCDM2a= "Secondary eligibility: w enrich [CDM basis]"
			eligibleCDM2b= "Secondary eligibility: wo enrich [CDM basis]"
			
		
        ;
    run;

    /* Check results */
    proc contents data=outlib.adaptable_prelim21;
    run;

    proc freq data=outlib.adaptable_prelim21;
        title "ADAPTABLE Phenotype CDM / Preliminary eligibility count";
        tables eligibleCDM;
    run;

%mend;

%main

 proc freq data=outlib.adaptable_prelim21;
        title "ADAPTABLE Phenotype CDM / Preliminary eligibility count";
        tables eligibleCDM eligibleCDM2a;
    run;
