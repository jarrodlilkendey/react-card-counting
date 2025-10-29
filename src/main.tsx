import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { createBrowserRouter } from "react-router";
import { RouterProvider } from "react-router/dom";

import "./index.css";

import CardCountingApp from "./components/CardCountingApp.tsx";
import LearnBasicStrategy from "./components/LearnBasicStrategy.tsx";
import LearnCardCounting from "./components/LearnCardCounting.tsx";

const router = createBrowserRouter([
  {
    path: "/",
    element: <CardCountingApp />,
  },
  {
    path: "/strategy",
    element: <LearnBasicStrategy />,
  },
  {
    path: "/card-counting",
    element: <LearnCardCounting />,
  },
]);

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
);
