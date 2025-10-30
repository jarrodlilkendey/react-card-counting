import { useState } from "react";

export interface ContactFormProps {
  title: string;
  description: string;
  fields: FormField[];
  submitButtonLabel: string;
  clearButtonLabel: string;
}

interface FormField {
  label: string;
  id: string;
  inputType: string;
  required: boolean;
}

interface FormData {
  [id: string]: string;
}

export default function ContactForm({
  title,
  description,
  fields,
  submitButtonLabel,
  clearButtonLabel,
}: ContactFormProps) {
  const [formData, setFormData] = useState<FormData>({});
  const [formResponse, setFormResponse] = useState<string>("");

  const handleFormFieldOnChange = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const newFormData = { ...formData };
    newFormData[event.target.id] = event.target.value;
    setFormData(newFormData);
  };

  const handleFormSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    console.log("handleFormSubmit", formData, event);

    try {
      const response = await fetch(import.meta.env.VITE_CONTACT_API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (response.ok) {
        setFormResponse("Thanks! We’ll be in touch shortly.");
        setFormData({});
      } else {
        const errText = await response.text();
        setFormResponse(`Something went wrong: ${errText}`);
      }
    } catch (error) {
      if (error instanceof Error)
        setFormResponse(`Something went wrong: ${error.message}`);
      else setFormResponse(`Something went wrong`);
    }
  };

  const handleFormClear = () => {
    setFormData({});
  };

  return (
    <div>
      <h1 className="text-3xl font-bold underline">{title}</h1>
      <h2 className="text-2xl font-bold">{description}</h2>
      <form
        className="border-2 border-b-black rounded-xs p-2"
        onSubmit={(event) => void handleFormSubmit(event)}
      >
        {fields.map((field: FormField) => (
          <div className="grid grid-cols-2 mb-2" key={`form-key-${field.id}`}>
            <label>{field.label}</label>

            <input
              type={field.inputType}
              id={field.id}
              required={field.required}
              className="border-1 border-b-black"
              onChange={(event) => handleFormFieldOnChange(event)}
              value={formData[field.id] ?? ""}
            />
          </div>
        ))}

        <input
          className="p-2 border-2 border-b-black rounded-xs"
          type="submit"
          value={submitButtonLabel}
        />

        <input
          className="p-2 ms-2 border-2 border-b-black rounded-xs"
          type="button"
          value={clearButtonLabel}
          onClick={() => handleFormClear()}
        />
      </form>

      {formResponse != "" && (
        <div>
          <p>{formResponse}</p>
        </div>
      )}
    </div>
  );
}
