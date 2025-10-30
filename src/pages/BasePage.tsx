import Header from "../components/Header";
import Footer from "../components/Footer";

interface Props {
  siteName: string;
  children: React.ReactNode;
}

export default function BasePage({ siteName, children }: Props) {
  return (
    <div>
      <Header siteName={siteName} />
      {children}
      <Footer siteName={siteName} />
    </div>
  );
}
