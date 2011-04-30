using System;
using PhotoDBDatabase.Classes;
using PhotoDBUserControls.Classes.MaxMind;
using umbraco.NodeFactory;

namespace PhotoDBUserControls
{
    public partial class ReferCounter : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["REFER_CHECK"] == null)
                {
                    Session["REFER_CHECK"] = new object();
                    StatsManager.CheckRefer();
                }
                int id = Node.GetCurrent().Id;
                StatsManager.MarkView(id, umbraco.library.NiceUrl(id), GeoIPHelper.CountryCode);
            }
        }
    }
}