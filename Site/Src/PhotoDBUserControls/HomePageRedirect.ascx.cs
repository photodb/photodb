using System;
using System.Web.UI;
using PhotoDBUserControls.Classes;
using umbraco.NodeFactory;
using UmbracoXmlModel;

namespace PhotoDBUserControls
{
    public partial class HomePageRedirect : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                string modeParam = Request[Constants.QueryString.ModeParam];
                switch(modeParam)
                {
                    case "help":
                        HomePage home = new HomePage(Node.getCurrentNodeId());
                        if (home.HelpPage.HasValue)
                            Response.Redirect(umbraco.library.NiceUrl(home.HelpPage.Value));
                        break;
                }
            }
        }
    }
}