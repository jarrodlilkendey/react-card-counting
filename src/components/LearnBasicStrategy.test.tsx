import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import LearnBasicStrategy from "./LearnBasicStrategy";

describe("LearnBasicStrategy Component", () => {
  it("h1 renders correct text", () => {
    render(<LearnBasicStrategy />);

    const heading = screen.getByRole("heading", {
      name: /Learn Basic Strategy/i,
    });

    expect(heading).toBeInTheDocument();
    expect(heading.tagName).toBe("H1");
  });
});
