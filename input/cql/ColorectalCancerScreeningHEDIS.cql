library ColorectalCancerScreeningHEDIS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '2.0.0'
//include hl7.fhir.uv.cql.FHIRHelpers version '4.0.1'
//include hl7.fhir.uv.cql.FHIRCommon version '2.0.0'

include ColorectalCancerElements called CCE

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.0-06:00, @2023-01-01T00:00:00.0-06:00)

context Patient

/*
NOTE: Removed Health Plan Enrollment criteria to simplify for demonstration purposes
NOTE: Age for HEDIS is based on the end of the MP, adjustment reflected below
*/
define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") in Interval[51, 75]

define "Denominator":
  "Initial Population"

define "Numerator":
  CCE."Has Appropriate Colorectal Cancer Screening"
    or CCE."Has History of Appropriate Colorectal Cancer Screening"

/*
NOTE: Removed hospice, advanced illness, and frailty exclusions to simplify for demonstration purposes
*/
define "Denominator Exclusion":
  CCE."Has Active Malignant Neoplasm" 
    or CCE."Has Total Colectomy Performed" 
    or CCE."Has History of Total Colectomy"
