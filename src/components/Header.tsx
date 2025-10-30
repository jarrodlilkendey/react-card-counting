interface Props {
  siteName: string;
}

export default function Header({ siteName }: Props) {
  return <p>Welcome to {siteName}</p>;
}
