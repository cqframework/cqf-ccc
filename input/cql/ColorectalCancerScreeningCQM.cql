library ColorectalCancerScreeningCQM version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

include ColorectalCancerElements called Elements

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.0-06:00, @2023-01-01T00:00:00.0-06:00)

context Patient

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") in Interval[50, 75]

define "Denominator":
  "Initial Population"

define "Numerator":
  Elements."Has Appropriate Colorectal Cancer Screening"

define "Denominator Exclusion":
  Elements."Has Active Malignant Neoplasm"
    or exists Elements."Total Colectomy Performed"
