library ColorectalCancerScreeningCQM version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

include ColorectalCancerElements called CCE

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0-06:00, @2020-01-01T00:00:00.0-06:00)

context Patient

/*
NOTE: Removed qualifying encounters criteria to simplify for demonstration purposes
*/
define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") in Interval[50, 75]

define "Denominator":
  "Initial Population"

define "Numerator":
  CCE."Has Appropriate Colorectal Cancer Screening"

/*
NOTE: Removed hospice, advanced illness, and frailty exclusions to simplify for demonstration purposes
*/
define "Denominator Exclusion":
  CCE."Has Active Malignant Neoplasm"
    or exists CCE."Total Colectomy Performed"
