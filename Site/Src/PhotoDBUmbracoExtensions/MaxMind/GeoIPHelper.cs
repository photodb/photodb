using System;
using System.Configuration;
using System.Web;
using CountryLookupProj;
using PhotoDBUmbracoExtensions.Classes;

namespace PhotoDBUmbracoExtensions.MaxMind
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

        public static GeoLocation GetIPLocation
        {
            get
            {
                try
                {
                    string fileName = ConfigurationManager.AppSettings["CityDatabase"];
                    LookupService ls = new LookupService(fileName, LookupService.GEOIP_STANDARD);
                    //get city location of the ip address
                    string userIp = HttpContext.Current.Request["ip"] ?? HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
                    if (!String.IsNullOrWhiteSpace(userIp))
                    {
                        Location l = ls.getLocation(userIp);
                        if (l != null)
                        {
                            return new GeoLocation()
                            {
                                Latitude = l.latitude,
                                Longitude = l.longitude,
                                Desc = (l.countryName ?? string.Empty) + " " + (l.city ?? string.Empty)
                            };
                        }
                        else
                        {
                            Console.Write("IP Address Not Found\n");
                        }
                    }
                    else
                    {
                        Console.Write("Usage: cityExample IPAddress\n");
                    }
                }
                catch{
                }
                return null;
            }
        }
    }
}