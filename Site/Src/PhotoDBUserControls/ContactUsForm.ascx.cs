using System;
using System.Web.UI;
using PhotoDBDatabase.Classes;
using PhotoDBUserControls.Classes;

namespace PhotoDBUserControls
{
    public partial class ContactUsForm : UmbracoUserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                btnSubmit.Text = GetProperty("submitText");
                UpdateValidators();
            }
        }

        private void UpdateValidators()
        {
            string errorMessage = GetProperty("requiredText");
            string incorrectFormat = GetProperty("invalidFormatText");

            rfvFirstName.ErrorMessage = String.Format(errorMessage, GetProperty("firstNameText"));
            rfvLastName.ErrorMessage = String.Format(errorMessage, GetProperty("lastNameText"));
            rfvEmail.ErrorMessage = String.Format(errorMessage, GetProperty("emailText"));
            revEmail.ErrorMessage = String.Format(incorrectFormat, GetProperty("emailText"));
            rfvOrganization.ErrorMessage = String.Format(incorrectFormat, GetProperty("organizationText"));
            rfvMessageText.ErrorMessage = String.Format(incorrectFormat, GetProperty("messageText"));
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (Page.IsValid)
            {
                ContactUsManager.LeaveMessage(txtFirstName.Text,
                    txtLastName.Text,
                    txtEmail.Text,
                    txtOrganization.Text,
                    txtTheme.Text,
                    txtMessageText.Text);
            }
        }
    }
}