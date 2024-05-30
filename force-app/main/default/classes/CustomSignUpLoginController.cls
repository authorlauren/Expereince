public class CustomLoginSignupController {
    // Login fields
    public String loginEmail { get; set; }
    public String loginPassword { get; set; }
    
    // Signup fields
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String signupEmail { get; set; }
    public String signupPassword { get; set; }

    // URLs for navigation
    public String getSignupPageUrl() {
        return Page.SignupPage.getUrl();
    }

    public String getLoginPageUrl() {
        return Page.LoginPage.getUrl();
    }

    // Login method
    public PageReference login() {
        try {
            PageReference pr = Site.login(loginEmail, loginPassword, null);
            if (pr != null) {
                pr.setRedirect(true);
                return pr;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Login failed. Please check your email and password.'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage()));
        }
        return null;
    }

    // Signup method
    public PageReference signup() {
        try {
            // Check if the username already exists
            List<User> existingUsers = [SELECT Id FROM User WHERE Username = :signupEmail LIMIT 1];
            if (!existingUsers.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Username already exists. Please use a different email address.'));
                return null;
            }

            // Create a new user
            User newUser = new User();
            newUser.FirstName = firstName;
            newUser.LastName = lastName;
            newUser.Email = signupEmail;
            newUser.Username = signupEmail + '.' + System.currentTimeMillis(); // Append timestamp to ensure uniqueness
            newUser.CommunityNickname = signupEmail;
            newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id; // Adjust profile as needed
            newUser.Alias = signupEmail.substring(0, 8);
            newUser.TimeZoneSidKey = 'America/Los_Angeles';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LanguageLocaleKey = 'en_US';

            insert newUser;

            // Set password
            System.setPassword(newUser.Id, signupPassword);

            // Optionally, auto-login the user after registration
            PageReference pr = Site.login(signupEmail, signupPassword, null);
            if (pr != null) {
                pr.setRedirect(true);
                return pr;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage()));
        }
        
        return null;
    }
}