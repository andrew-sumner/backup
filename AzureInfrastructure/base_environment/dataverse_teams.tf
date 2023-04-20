# Test and Prod tenant team to role mapping

locals {
  # Find AD Groups belonging to the tenant (filters on domain)
  filter_teams = {
    value = { for k, v in local.teams :  k => v if length(regexall("(?i)${module.global_variables.azure.ad_domain}.*", v.group)) > 0}
  }

  teams = {
    ice_area_manager = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Area-Manager"
      roles     = ["ICE Area Manager"]
      team_guid = "022d3f8b-3b55-4342-a619-cbdd2a046468"
    },
    ice_business_admin = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-Business-Administrator"
      roles     = ["ICE Business Administrator"]
      team_guid = "958bdb50-5bfe-415a-980e-94db849ba466"
    },
    ice_cci_user = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-User"
      roles     = ["ICE CCI User"]
      team_guid = "1e98d61f-a81a-4497-a0a0-fa26c12c8bdb"
    },
    ice_core_aog_user = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-Core-AOG-User"
      roles     = ["ICE Core AOG User"]
      team_guid = "6f2f6924-4f6f-ed11-9562-002248e16613"
    },
    ice_crg_lender = {
      group     = "CorpNZ-Access-D365-CRG"
      roles     = ["ICE CRG Lender"]
      team_guid = "3a8f1fac-0ea6-498c-9f5e-1106b78de2bf"
    },
    crg_reporting_view_only = {
      group     = "CorpNZ-Access-D365-CRG-Reporting-View"
      roles     = ["CRG Reporting - View only"]
      team_guid = "3c116ed1-1ba7-ed11-aad0-002248e16215"
    },
    ice_cs_credit_manager = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Credit-Manager"
      roles     = ["ICE Credit Manager"]
      team_guid = "cb968140-946b-4e5c-9d72-3f0017ef6523"
    },
    ice_cs_legal_officer = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Legal-Officer"
      roles     = ["ICE Legal Officer"]
      team_guid = "c7c98811-8c8c-4f60-80e0-075f4584947f"
    },
    ice_cs_lending_officer = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Lending-Officer"
      roles     = ["ICE Lending Officer"]
      team_guid = "3563cd7a-e05b-4374-9d2a-d334649f0ba7"
    },
    ice_cs_pricing_officer = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Pricing-Officer"
      roles     = ["ICE Pricing Officer"]
      team_guid = "7ca4a2c8-b85a-4a8b-9bd6-59e64fa7e54c"
    },
    ice_cs_regional_manager = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Regional-Manager"
      roles     = ["ICE Regional Manager"]
      team_guid = "9cea84d9-c076-46ae-b209-a0c9d38a0391"
    },
    ice_letter_off_offer_pilot = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-Letter-Of-Offer-Pilot"
      roles     = ["ICE Letter Of Offer Pilot"]
      team_guid = "003634f0-5d14-ed11-82e4-002248d3965f"
    },
    ice_pace_administrator = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-PACE-Administrator"
      roles     = ["ICE PACE Administrator"]
      team_guid = "597902af-1c07-461c-81d8-0bd682ee94aa"
    },
    ice_relationship_manager = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Relationship-Manager-and-Analyst"
      roles     = ["ICE Relationship Manager"]
      team_guid = "df667c99-30f8-424a-a641-064137258a9b"
    },
    ice_responsible_officer = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-CS-Responsible-Officer"
      roles     = ["ICE Responsible Officer"]
      team_guid = "fca8000e-4b66-48f8-a47c-96c30276d4b5"
    },
    ice_read_only_administrator = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-ICE-Read-Only-Administrator"
      roles     = ["ICE Read Only Administrator"]
      team_guid = "fed165c0-95e7-4827-8aab-850d0edeebfc"
    },
    ice_sustainable_finance  = {
      group     = "CorpNZ-Access-D365-ICE-Sustainable-Finance"
      roles     = ["ICE Sustainable Finance"]
      team_guid = "4602ef8f-556c-ed11-9562-002248e16417"
    },
    ice_team = {
      group     = "CorpNZ-Access-D365-ICE-Team"
      roles     = []
      team_guid = "d2125341-a2fb-486e-806e-1aff16568d40"
    },
    ice_wib_user  = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-WIB-User"
      roles     = ["ICE WIB User"]
      team_guid = "4de12185-f1e3-49c5-9014-fa9ad5728d12"
    },
    ice_wib_rss_user  = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-WIB-RSS-User"
      roles     = ["ICE WIB RSS User"]
      team_guid = "f5336c9d-1b54-413c-8e0f-fed5cd6de87e"
    },
    ice_wib_team  = {
      group     = "${module.global_variables.azure.ad_domain}-Access-D365-WIB-Team"
      roles     = []
      team_guid = "22ac638a-63ba-4af4-bbb8-57785f8e997f"
    },
    # Owned by William Duckworth (ICEBreakers squad), while not part of ICE they don't have an Azure Subscription
    # so easier to keep here.
    dwp_diarycards_app_users  = {
      group     = "CorpNZ-Access-D365-DWP-DiaryCards-App-Users"
      roles     = ["Digital Work Place - Diary Cards Application Users"]
      team_guid = "0587da07-b3ab-464b-b5c4-7b974e2a2f29"
    },
    dwp_internationalcustomers_app_users  = {
      group     = "CorpNZ-Access-D365-DWP-InternationalBusinessCustomers-App-Users"
      roles     = ["Digital Work Place - International Business Customers Application Users"]
      team_guid = "c05feb13-9485-45ad-b895-d4b1a6117ea5"
    },
    dwp_clientservices_app_users  = {
      group     = "CorpNZ-Access-D365-DWP-ClientServicesInstitutional-App-Users"
      roles     = ["Digital Work Place - Client Services Institutional Application Users"]
      team_guid = "06c77db2-55d3-467f-ab6e-87407dc874df"
    },
    dwp_aom_app_users  = {
      group     = "CorpNZ-Access-D365-DWP-AOM-App-Users"
      roles     = ["Digital Work Place - Active Operations Management App Users"]
      team_guid = "dcba8f8a-6cce-4289-95e9-89e8c53357cf"
    },
    dwp_aom_champions_users  = {
      group     = "CorpNZ-Access-D365-DWP-AOM-Champion-Users"
      roles     = ["Digital Work Place - Active Operations Management Champions"]
      team_guid = "ed7925ab-2b77-460f-8f5f-d695cf24e510"
    },
    dwp_aom_champions_ownership_users  = {
      group     = "CorpNZ-Access-D365-DWP-AOM-App-Champion-Ownership-Users"
      roles     = ["Digital Work Place - Active Operations Management Champions Ownership"]
      team_guid = "7af5d3f6-3386-46fd-a589-cad4c29d5176"
    },
    dwp_billpayee_app_users  = {
      group     = "CorpNZ-Access-D365-DWP-WPTBillPayee-App-Users"
      roles     = ["Digital Work Place - WPT Bill Payee User"]
      team_guid = "65d6a10a-57a9-4016-8bc4-4c37f5570160"
    }
  }
}

# Apply 
module "d365_teams" {
  source = "git::https://stash.westpac.co.nz/scm/cp/terraform-azure-d365.git//d365_aad_team?ref=master"

  for_each = local.filter_teams.value

  dynamics365_connection_string = nonsensitive(module.d365_connection_string.value)
  AADGroupName                  = each.value.group
  AdministratorEmail            = module.global_variables.azure.ad_team_owner_email
  RoleNames                     = each.value.roles
  TeamId                        = each.value.team_guid
}
