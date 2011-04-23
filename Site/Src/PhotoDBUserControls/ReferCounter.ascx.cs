using System;
using PhotoDBDatabase.Classes;

namespace PhotoDBUserControls
{
    public partial class ReferCounter : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["REFER_CHECK"] == null)
            {
                Session["REFER_CHECK"] = new object();
                StatsManager.CheckRefer();
            }
        }
    }
}