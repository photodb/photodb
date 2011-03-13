<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ContactUsForm.ascx.cs" Inherits="PhotoDBUserControls.ContactUsForm" %>

<asp:MultiView runat="server" ID="mvMain" ActiveViewIndex="0">
    <asp:View runat="server" ID="vForm">

        <div class="validation_summary">
            <asp:ValidationSummary runat="server" ID="vsContactUs" ShowMessageBox="false" ShowSummary="true"
                        DisplayMode="List" CssClass="red" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvFirstName" ControlToValidate="txtFirstName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvLastName" ControlToValidate="txtLastName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvEmail" ControlToValidate="txtEmail" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RegularExpressionValidator runat="server"
                        ID="revEmail"   
                        ControlToValidate="txtEmail" Display="None"  
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                        SetFocusOnError="true" ValidationGroup="vgContactUs"/>
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvOrganization" ControlToValidate="txtOrganization" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvMessageText" ControlToValidate="txtMessageText" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
        </div>

        <div class="form">
	        <div class="row required">
                <div class="row_label" ><%= GetProperty("firstNameText") %>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtFirstName" CssClass="standartInput" MaxLength="100" />
            </div>
	        <div class="row required">
                <div class="row_label" ><%= GetProperty("lastNameText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtLastName" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("emailText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtEmail" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("organizationText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtOrganization" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row optional">
                <div class="row_label"><%= GetProperty("themeText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtTheme" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("messageText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtMessageText" CssClass="multilineInput" TextMode="MultiLine" Rows="7" Columns="30" />
            </div>
            <div class="row">
                <asp:Button runat="server" ID="btnSubmit" CssClass="standartBtn" 
                    onclick="btnSubmit_Click" ValidationGroup="vgContactUs" />
            </div>
        </div>

    </asp:View> 
    <asp:View runat="server" ID="vThankYouMessage">
        <asp:Literal runat="server" ID="ltrThankYouMessage" Mode="PassThrough" />
    </asp:View>
</asp:MultiView>
