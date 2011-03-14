using System;
using PhotoDBDatabase.Classes;
using umbraco.cms.businesslogic.media;
using umbraco.cms.businesslogic.property;

namespace PhotoDBUserControls
{
    public partial class DownloadHandler : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string sFileParam = Request["file"];
            int mediaId;
            if (Int32.TryParse(sFileParam, out mediaId))
            {
                Media m = new Media(mediaId);
                Property p = m.getProperty("installerFile");
                if (p == null)
                    throw new InvalidProgramException(String.Format("Can't find property 'installerFile' in media {0}", mediaId));
                string filePath = (string)p.Value;
                if (!String.IsNullOrEmpty(filePath))
                {
                    int pageId = umbraco.NodeFactory.Node.GetCurrent().Id;
                    DownloadManager.NewDownload(mediaId, pageId, Request.RawUrl, filePath);
                    Response.Redirect(filePath);
                }
            }
        }
    }
}