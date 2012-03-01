using System;
using System.Linq;
using System.Web.UI;
using PhotoDBUserControls.Classes;
using umbraco.NodeFactory;
using UmbracoXmlModel;
using Action = UmbracoXmlModel.Action;

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

                string actionParam = Request[Constants.QueryString.ActionParam];
                if (!String.IsNullOrEmpty(actionParam) && actionParam.All(Char.IsLetter))
                {
                    HomePage home = new HomePage(Node.getCurrentNodeId());
                    string actionPath = String.Format(@"root/descendant-or-self::SiteSettings/descendant::*[@nodeName='{0}']/descendant::Action[handler='{1}']", home.NodeName, actionParam);
                    Action action = new Action(actionPath);
                    if (!action.Empty)
                    {
                        if (action.Node.HasValue)
                            Response.Redirect(umbraco.library.NiceUrl(action.Node.Value));
                    }
                }
            }
        }
    }
}