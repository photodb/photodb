
namespace PhotoDBUmbracoExtensions
{
    public static class UmbracoHelper
    {
        public static bool IsLoggedIntoBackend
        {
            get
            {
                var u = umbraco.helper.GetCurrentUmbracoUser();
                if (u == null)
                    return false;
                else
                    return true;
            }
        }
    }
}
