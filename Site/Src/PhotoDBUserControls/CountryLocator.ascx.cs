using System;
using System.Configuration;
using System.Web;
using CountryLookupProj;
using PhotoDBUserControls.Classes.MaxMind;

namespace PhotoDBUserControls
{
    public partial class CountryLocator : System.Web.UI.UserControl
    {
        private const string SESSION_ID = "IP_LOCATION";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session[SESSION_ID] == null && Request.Url.Query.Length < 2)
                {
                    Session[SESSION_ID] = DateTime.Now;
                    string userCountryCode = GeoIPHelper.CountryCode;
                    if (!String.IsNullOrEmpty(userCountryCode))
                    {
                        userCountryCode = userCountryCode.ToUpper();
                        string redirectConfiguration = ConfigurationManager.AppSettings["CountryIPSelection"] ?? String.Empty;
                        string[] countrySettings = redirectConfiguration.Split(';');
                        foreach (string countrySetting in countrySettings)
                        {
                            string[] options = countrySetting.Split(':');
                            foreach (string countryCode in options[1].Split(','))
                            {
                                if (countryCode == userCountryCode)
                                {
                                    string path = options[0];
                                    Response.Redirect("/" + path);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}