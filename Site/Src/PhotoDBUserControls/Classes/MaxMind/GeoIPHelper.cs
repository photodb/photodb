using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using CountryLookupProj;

namespace PhotoDBUserControls.Classes.MaxMind
{
    public static class GeoIPHelper
    {
        public static string CountryCode
        {
            get
            {
                if (HttpContext.Current.Session["COUNTRY_CODE"] == null)
                {
                    string fileName = ConfigurationManager.AppSettings["IPDatabase"];
                    CountryLookup lookup = new CountryLookup(fileName);
                    string userIp = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
                    string countryCode = lookup.lookupCountryCode(userIp);
                    HttpContext.Current.Session["COUNTRY_CODE"] = countryCode;
                    return countryCode;
                }
                else
                {
                    return (string)HttpContext.Current.Session["COUNTRY_CODE"];
                }
            }
        }
    }
}