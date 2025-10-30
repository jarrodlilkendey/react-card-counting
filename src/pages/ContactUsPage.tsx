import BasePage from "./BasePage";
import { siteConfig } from "../config/site.config";

import ContactForm from "../components/ContactForm";
import type { ContactFormProps } from "../components/ContactForm";

const form: ContactFormProps = {
  title: "Contact Us",
  description: "Get in contact with us about our react card counting app",
  fields: [
    {
      label: "First Name",
      id: "firstName",
      inputType: "text",
      required: true,
    },
    {
      label: "Phone",
      id: "phone",
      inputType: "text",
      required: true,
    },
    {
      label: "Email",
      id: "email",
      inputType: "email",
      required: true,
    },
    {
      label: "Enquiry",
      id: "enquiry",
      inputType: "text",
      required: true,
    },
  ],
  submitButtonLabel: "Submit",
  clearButtonLabel: "Clear",
};

export default function ContactUsPage() {
  return (
    <BasePage siteName={siteConfig.siteName}>
      <ContactForm {...form} />
    </BasePage>
  );
}
