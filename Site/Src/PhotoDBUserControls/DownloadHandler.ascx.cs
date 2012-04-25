using System;
using System.Collections.Generic;
using PhotoDBDatabase.Classes;
using PhotoDBUmbracoExtensions;
using PhotoDBUmbracoExtensions.MaxMind;
using UmbracoXmlModel;

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
                Release release = new Release(iNodeId);
                
                int? mediaId = release.InstallerFile;
                if (mediaId.HasValue)
                {
                    MediaRelease mediaRelease = new MediaRelease(mediaId.Value, false);

                    string filePath = mediaRelease.InstallerFile;
                    if (!String.IsNullOrEmpty(filePath))
                    {
                        List<RandomDownload> downloads = new List<RandomDownload>();
                        downloads.Add(new RandomDownload()
                        {
                            DownloadPage = filePath, //default media file
                            Weight = 1,
                        });
                        int commonWeight = 1;
                        foreach (DownloadMirror mirror in release.ChildsOfType<DownloadMirror>())
                        {
                            if (mirror.Weight.HasValue)
                            {
                                downloads.Add(new RandomDownload()
                                {
                                    DownloadPage = mirror.Urllocation,
                                    Weight = mirror.Weight.Value,
                                });
                                commonWeight += mirror.Weight.Value;
                            }
                        }
                        int downloadPageWeight = _rnd.Next(commonWeight) + 1;
                        int currentWeight = 0;
                        foreach (RandomDownload d in downloads)
                        {
                            currentWeight += d.Weight;
                            if (currentWeight >= downloadPageWeight)
                            {
                                int pageId = umbraco.NodeFactory.Node.getCurrentNodeId();
                                if (!UmbracoHelper.IsLoggedIntoBackend && !HttpHelper.UserIsCrawler)
                                {
                                    if (DownloadManager.NewDownload(mediaId.Value, pageId, Request.RawUrl, d.DownloadPage, GeoIPHelper.CountryCode))
                                    {
                                        MailData data = new MailData();
                                        data.Add("HostId", StatsManager.HostId.ToString());
                                        data.Add("MediaId", mediaId.Value.ToString());
                                        data.Add("PageId", pageId.ToString());
                                        data.Add("Request", Request.RawUrl);
                                        data.Add("Download Page", d.DownloadPage);
                                        data.Add("ConuntryCode", GeoIPHelper.CountryCode);
                                        Mailer.MailNotify("Download", data);
                                    }
                                }

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