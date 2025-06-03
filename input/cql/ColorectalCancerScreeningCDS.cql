library ColorectalCancerScreeningCDS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include ColorectalCancerCommon called Common
include ColorectalCancerElements called Elements

context Patient

define "Is Recommendation Applicable":
  AgeInYears() between 50 and 75
    and not Elements."Has Appropriate Colorectal Cancer Screening"
    and not Elements."Has Active Malignant Neoplasm"
    and not exists (Elements."Total Colectomy Performed")

define "Get Card Summary":
  if "Is Recommendation Applicable" then
    'Recommend appropriate colorectal cancer screening'
  else
    'Patient has appropriate colorectal cancer screening'

define "Get Card Detail":
  if "Is Recommendation Applicable" then
    'Patient meets the inclusion criteria for appropriate colorectal cancer screening, but has ' + Rationale + '.'
  else
    'Patient has appropriate colorectal cancer screening: ' + Rationale + '.'

define "Rationale":
  Coalesce({
    'most recent FOBT issued on ' + ToString(date from Elements."Most Recent Fecal Occult Blood Test Result".issued),
    'most recent FIT DNA issued on ' + ToString(date from Elements."Most Recent Fecal Immunochemical Test DNA Result".issued),
    'most recent CT Colonography performed on ' + ToString(date from start of Elements."Most Recent CT Colonography Performed".performed.toInterval()),
    'most recent Flexible Sigmoidoscopy performed on ' + ToString(date from start of Elements."Most Recent Flexible Sigmoidoscopy Performed".performed.toInterval()),
    'most recent Colonoscopy performed on ' + ToString(date from start of Elements."Most Recent Colonoscopy Performed".performed.toInterval()),
    'no evidence of appropriate screening'
  })

define "Get Card Indicator":
  if "Is Recommendation Applicable" then
    'warning'
  else
    'info'
