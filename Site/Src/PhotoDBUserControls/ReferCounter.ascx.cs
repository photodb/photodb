using System;
using PhotoDBDatabase.Classes;
using PhotoDBUmbracoExtensions;
using PhotoDBUmbracoExtensions.MaxMind;
using umbraco.NodeFactory;

namespace PhotoDBUserControls
{
    public partial class ReferCounter : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!UmbracoHelper.IsLoggedIntoBackend)
                {
                    if (Session["REFER_CHECK"] == null)
                    {
                        Session["REFER_CHECK"] = new object();
                        StatsManager.CheckRefer();
                    }
                    int id = Node.getCurrentNodeId();
                    StatsManager.MarkView(id, umbraco.library.NiceUrl(id) + Request.Url.Query, GeoIPHelper.CountryCode);
                }
            }
        }
    }
}