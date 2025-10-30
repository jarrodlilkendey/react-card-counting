interface Props {
  siteName: string;
}

const year = new Date().getFullYear();

export default function Footer({ siteName }: Props) {
  return (
    <footer>
      <p>
        {siteName} | Copyright {year} - All Rights Reserved
      </p>
    </footer>
  );
}
