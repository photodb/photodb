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
                string fileName = ConfigurationManager.AppSettings["IPDatabase"];
                CountryLookup lookup = new CountryLookup(fileName);
                string userIp = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
                return lookup.lookupCountryCode(userIp);
            }
        }
    }
}