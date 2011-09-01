<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BuyForm.ascx.cs" Inherits="PhotoDBUserControls.BuyForm" %>

<asp:MultiView runat="server" ID="mvMain" ActiveViewIndex="0">
    <asp:View runat="server" ID="vForm">

        <div class="validation_summary">
            <asp:ValidationSummary runat="server" ID="vsBuy" ShowMessageBox="false" ShowSummary="true"
                        DisplayMode="List" CssClass="red" ValidationGroup="vgBuy" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvFirstName" ControlToValidate="txtFirstName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgBuy" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvLastName" ControlToValidate="txtLastName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgBuy" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvEmail" ControlToValidate="txtEmail" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgBuy" />
            <asp:RegularExpressionValidator runat="server"
                        ID="revEmail"   
                        ControlToValidate="txtEmail" Display="None"  
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                        SetFocusOnError="true" ValidationGroup="vgBuy"/>
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
            <div class="row">
                <div class="row_label"><%= GetProperty("phoneText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtPhone" CssClass="standartInput" MaxLength="20" />
            </div>
            <div class="row">
                <div class="row_label"><%= GetProperty("countryText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtContry" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row">
                <div class="row_label"><%= GetProperty("cityText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtCity" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row">
                <div class="row_label"><%= GetProperty("addressText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtAddress" CssClass="standartInput" MaxLength="200" />
            </div>
            <div class="row">
                <div class="row_label"><%= GetProperty("appCodeText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtAppCode" CssClass="standartInput" MaxLength="200" ReadOnly="true" />
                <asp:HiddenField runat="server" ID="hvProgramVersion" />
            </div>
            <div class="row">
                <asp:Button runat="server" ID="btnSubmit" CssClass="standartBtn" onclick="btnSubmit_Click" ValidationGroup="vgBuy" />
            </div>
        </div>

    </asp:View> 
    <asp:View runat="server" ID="vThankYouMessage">
        <asp:Literal runat="server" ID="ltrThankYouMessage" Mode="PassThrough" />
    </asp:View>
</asp:MultiView>