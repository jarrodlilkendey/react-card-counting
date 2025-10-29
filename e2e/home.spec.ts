import { test, expect } from "@playwright/test";

test.describe("Home Page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveURL("/");
  });

  test("title and heading are correct", async ({ page }) => {
    await expect(page).toHaveTitle("react-card-counting");
    await expect(
      page.getByRole("heading", {
        name: "Card Counting App",
      })
    ).toBeVisible();
  });

  test("home page links are displayed", async ({ page }) => {
    await expect(
      page.getByRole("link", { name: "Basic Strategy" })
    ).toBeVisible();

    await expect(
      page.getByRole("link", { name: "Card Counting" })
    ).toBeVisible();
  });

  test("home page Learn Basic Strategy link redirects with correct path and heading", async ({
    page,
  }) => {
    page
      .getByRole("link", {
        name: "Basic Strategy",
      })
      .click();

    await expect(page).toHaveURL("/strategy");
    await expect(
      page.getByRole("heading", {
        name: "Basic Strategy",
      })
    ).toBeVisible();
    await expect(page).toHaveTitle("react-card-counting");
  });

  test("home page Learn Card Counting link redirects with correct path and heading", async ({
    page,
  }) => {
    page
      .getByRole("link", {
        name: "Card Counting",
      })
      .click();

    await expect(page).toHaveURL("/card-counting");
    await expect(
      page.getByRole("heading", {
        name: "Card Counting",
      })
    ).toBeVisible();
    await expect(page).toHaveTitle("react-card-counting");
  });
});
