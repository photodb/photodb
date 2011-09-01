using System;
using System.Collections.Generic;
using PhotoDBDatabase.Classes;
using PhotoDBUmbracoExtensions;
using PhotoDBUserControls.Classes.MaxMind;
using umbraco.cms.businesslogic.media;
using umbraco.cms.businesslogic.property;
using umbraco.interfaces;

namespace PhotoDBUserControls
{
    public partial class DownloadHandler : System.Web.UI.UserControl
    {
        private static Random _rnd = new Random(DateTime.Now.Millisecond);

        private class RandomDownload
        {
            public string DownloadPage;
            public int Weight;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string sNodeIdParam = Request["id"];
            int iNodeId;
            if (Int32.TryParse(sNodeIdParam, out iNodeId))
            {
                umbraco.NodeFactory.Node node = new umbraco.NodeFactory.Node(iNodeId);

                IProperty propMediaId = node.GetProperty("installerFile");
                int mediaId;
                if (Int32.TryParse(propMediaId.Value, out mediaId))
                {
                    Media m = new Media(mediaId);
                    Property installerFileProp = m.getProperty("installerFile");
                    if (installerFileProp == null)
                        throw new InvalidProgramException(String.Format("Can't find property 'installerFile' in media {0}", mediaId));

                    string filePath = (string)installerFileProp.Value;
                    if (!String.IsNullOrEmpty(filePath))
                    {

                        List<RandomDownload> downloads = new List<RandomDownload>();
                        downloads.Add(new RandomDownload()
                        {
                            DownloadPage = filePath, //default media file
                            Weight = 1,
                        });
                        int commonWeight = 1;
                        foreach (umbraco.NodeFactory.Node n in node.Children)
                        {
                            IProperty propWeight = n.GetProperty("weight");
                            int iWeight;
                            if (Int32.TryParse(propWeight.Value, out iWeight))
                            {
                                IProperty propUrl = n.GetProperty("urlLocation");
                                downloads.Add(new RandomDownload()
                                {
                                    DownloadPage = propUrl.Value,
                                    Weight = iWeight,
                                });
                                commonWeight += iWeight;
                            }
                        }
                        int downloadPageWeight = _rnd.Next(commonWeight) + 1;
                        int currentWeight = 0;
                        foreach (RandomDownload d in downloads)
                        {
                            currentWeight += d.Weight;
                            if (currentWeight >= downloadPageWeight)
                            {
                                int pageId = umbraco.NodeFactory.Node.GetCurrent().Id;
                                if (!UmbracoHelper.IsLoggedIntoBackend && !HttpHelper.UserIsCrawler)
                                    DownloadManager.NewDownload(mediaId, pageId, Request.RawUrl, d.DownloadPage, GeoIPHelper.CountryCode);

                                MailData data = new MailData();
                                data.Add("MediaId", mediaId.ToString());
                                data.Add("PageId", pageId.ToString());
                                data.Add("Request", Request.RawUrl);
                                data.Add("Download Page", d.DownloadPage);
                                data.Add("ConuntryCode", GeoIPHelper.CountryCode);
                                Mailer.MailNotify("Download", data);

                                Response.Redirect(d.DownloadPage);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}