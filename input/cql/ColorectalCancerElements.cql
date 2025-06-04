library ColorectalCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '2.0.0'
//include hl7.fhir.uv.cql.FHIRHelpers version '4.0.1'
//include hl7.fhir.uv.cql.FHIRCommon version '2.0.0'

include ColorectalCancerConcepts called Concepts

parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 1 year, Now()]

context Patient

define AsOf:
  end of "Measurement Period"

define "Has Appropriate Colorectal Cancer Screening":
  exists "Fecal Occult Blood Test Result Within 1 Year"
    or exists "Fecal Immunochemical Test DNA Result Within 3 Years"
    or exists "CT Colonography Performed Within 5 Years"
    or exists "Flexible Sigmoidoscopy Performed Within 5 Years"
    or exists "Colonoscopy Performed Within 10 Years"

define "Fecal Occult Blood Test Result Within 1 Year":
  "Fecal Occult Blood Test Result" R
    where R.issued 1 year or less on or before AsOf

define "Fecal Occult Blood Test Result":
  [Observation: Concepts."Fecal Occult Blood Test (FOBT)"] FecalOccultResult
		where FecalOccultResult.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FecalOccultResult.value is not null

/*
@description: Completed Flexible Sigmoidoscopy Procedures
*/
define "Flexible Sigmoidoscopy Performed":
  [Procedure: Concepts."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'

// NOTE: HEDIS version allows for a "history of" SNOMED code as FHIR.Condition. Code is present in eCQM valueset.
define "Flexible Sigmoidoscopy from Patient History":
  [Condition: Concepts."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopyCondition
    where FlexibleSigmoidoscopyCondition.isActive()
      and FlexibleSigmoidoscopyCondition.isConfirmed()

define "CT Colonography Performed":
  [Procedure: Concepts."CT Colonography"] Colonography
    where Colonography.status = 'completed'

define "Total Colectomy Performed":
  [Procedure: Concepts."Total Colectomy"] Colectomy
    where Colectomy.status = 'completed'

// NOTE: HEDIS version allows for a "history of" SNOMED code as FHIR.Condition. Code is present in eCQM valueset.
define "Total Colectomy from Patient History":
  [Condition: Concepts."Total Colectomy"] ColectomyCondition
    where ColectomyCondition.isActive()
      and ColectomyCondition.isConfirmed()

define "Fecal Immunochemical Test DNA Result":
  [Observation: Concepts."FIT DNA"] FitDNA
		where FitDNA.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FitDNA.value is not null

define "Colonoscopy Performed":
  [Procedure: Concepts."Colonoscopy"] Colonoscopy
		where Colonoscopy.status = 'completed'

// NOTE: HEDIS version allows for a "history of" SNOMED code as FHIR.Condition. Code is present in eCQM valueset.
define "Colonoscopy from Patient History":
  [Condition: Concepts."Colonoscopy"] C
    where C.isActive()
    and C.isConfirmed()

define "Active Malignant Neoplasm":
  [Condition: Concepts."Malignant Neoplasm of Colon"] ColorectalCancer
    where ColorectalCancer.isActive()
      and ColorectalCancer.isConfirmed()

define "Most Recent Fecal Occult Blood Test Result":
  MostRecent("Fecal Occult Blood Test Result", AsOf)

define "Fecal Immunochemical Test DNA Result Within 3 Years":
  "Fecal Immunochemical Test DNA Result" R
    where R.issued 3 years or less on or before AsOf

define "Most Recent Fecal Immunochemical Test DNA Result":
  MostRecent("Fecal Immunochemical Test DNA Result", AsOf)

define "Flexible Sigmoidoscopy Performed Within 5 Years":
  "Flexible Sigmoidoscopy Performed" P
    where P.performed.toInterval() ends 5 years or less on or before AsOf

define "Most Recent Flexible Sigmoidoscopy Performed":
  MostRecent("Flexible Sigmoidoscopy Performed", AsOf)

define "CT Colonography Performed Within 5 Years":
  "CT Colonography Performed" P
    where P.performed.toInterval() ends 5 years or less on or before AsOf

define "Most Recent CT Colonography Performed":
  MostRecent("CT Colonography Performed", AsOf)

define "Colonoscopy Performed Within 10 Years":
  "Colonoscopy Performed" P
    where P.performed.toInterval() ends 10 years or less on or before AsOf

define "Most Recent Colonoscopy Performed":
  MostRecent("Colonoscopy Performed", AsOf)

define "Has Active Malignant Neoplasm":
  exists (
    "Active Malignant Neoplasm" M
      where M.prevalenceInterval() starts on or before AsOf
  )

// NOTE: Added these two for HEDIS version.
define "Has Total Colectomy Performed":
  exists (
    PerformedWithin("Total Colectomy Performed", 1 year)
  )

define "Has History of Total Colectomy":
 exists (
    "Total Colectomy from Patient History" ColectomyHistory
      where ColectomyHistory.prevalenceInterval() starts on or before AsOf
  )

/*
  FOBT within 1 year
    or FIT DNA within 3 years
    or CT Colonography within 5 years
    or Flexible Sigmoidoscopy within 5 years
    or Colonoscopy within 10 years
*/

// NOTE: For Condition options
define "Has History of Appropriate Colorectal Cancer Screening":
  exists (
    "Flexible Sigmoidoscopy from Patient History" FlexSigCondition
      where FlexSigCondition.prevalenceInterval() starts on or after day of AsOf - 5 years)
  or exists (
    "Colonoscopy from Patient History" ColonscopyCondition
      where ColonscopyCondition.prevalenceInterval() starts on or after day of AsOf - 10 years)

define function MostRecent(procedures List<Procedure>, asOf DateTime):
  First(
    procedures P
      where P.performed.toInterval() ends on or before asOf
      sort by start of performed.toInterval()
  )

define function MostRecent(observations List<Observation>, asOf DateTime):
  First(
    observations O
      sort by issued
  )

define function IssuedWithin(observations List<Observation>, lookback System.Quantity):
  observations O
    where O.issued on or after day of AsOf - lookback

define function PerformedWithin(procedures List<Procedure>, lookback System.Quantity):
  procedures P
    where end of P.performed.toInterval() on or after day of AsOf - lookback
