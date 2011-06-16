using System;
using System.Configuration;

namespace PhotoDBUmbracoExtensions
{
    public static class HttpHelper
    {
        public static bool UserIsCrawler
        {
            get
            {
                string crawlersUserAgents = ConfigurationManager.AppSettings["CrawlerUserAgents"];
                if (String.IsNullOrEmpty(crawlersUserAgents))
                    crawlersUserAgents = "gsa-crawler,Googlebot,YahooSeeker,Slurp";
                crawlersUserAgents = crawlersUserAgents.ToLower();

                string browser = System.Web.HttpContext.Current.Request.Headers.Get("User-Agent");
                if (String.IsNullOrEmpty(browser))
                    browser = "undefined";
                browser = browser.ToLower();

                foreach (string userAgent in crawlersUserAgents.Split(','))
                {
                    bool isCrawler = browser.IndexOf(userAgent) > -1;
                    if (isCrawler)
                        return true;
                }
                return false;
            }
        }

     
    }
}
