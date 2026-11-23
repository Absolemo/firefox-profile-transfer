const HOST = "org.absolem.firefox_profile_transfer";

async function nativeRequest(message) {
    return browser.runtime.sendNativeMessage(HOST, message);
}

async function loadProfiles() {
    const response = await nativeRequest({
        action: "list_profiles"
    });

    if (!response.ok) {
        throw new Error(response.error || "Profile konnten nicht geladen werden");
    }

    return response.profiles;
}

async function createMenus() {
    await browser.menus.removeAll();

    browser.menus.create({
        id: "profile-transfer",
        title: "Send to another profile",
        contexts: ["tab"]
    });

    let profiles;

    try {
        profiles = await loadProfiles();
    } catch (error) {
        console.error("Profile detection failed:", error);
        return;
    }

    browser.menus.create({
        id: "selected-tabs",
        parentId: "profile-transfer",
        title: "Send selected tabs",
        contexts: ["tab"]
    });

    for (const profile of profiles) {
        browser.menus.create({
            id: `selected:${profile}`,
            parentId: "selected-tabs",
            title: profile,
            contexts: ["tab"]
        });
    }

    browser.menus.create({
        id: "separator",
        parentId: "profile-transfer",
        type: "separator",
        contexts: ["tab"]
    });

    browser.menus.create({
        id: "all-tabs",
        parentId: "profile-transfer",
        title: "Send all tabs in this window",
        contexts: ["tab"]
    });

    for (const profile of profiles) {
        browser.menus.create({
            id: `all:${profile}`,
            parentId: "all-tabs",
            title: profile,
            contexts: ["tab"]
        });
    }
}

async function getSelectedTabs(clickedTab) {
    const highlighted = await browser.tabs.query({
        highlighted: true,
        windowId: clickedTab.windowId
    });

    if (clickedTab.highlighted && highlighted.length > 1) {
        return highlighted;
    }

    return [clickedTab];
}

async function sendTabs(tabs, profile) {
    const urls = tabs
        .filter(tab => tab.url)
        .map(tab => tab.url);

    if (urls.length === 0) {
        console.error("No transferable tabs found.");
        return;
    }

    const response = await nativeRequest({
        action: "transfer",
        profile: profile,
        urls: urls
    });

    if (!response.ok) {
        throw new Error(response.error || "Transfer failed");
    }

    const count = response.count;
    const tabLabel = count === 1 ? "tab" : "tabs";

    console.log(
        `${count} ${tabLabel} successfully sent to ${profile}.`
    );

    if (response.skipped > 0) {
        console.warn(`${response.skipped} unsupported tab(s) skipped.`);
    }

    if (response.failed > 0) {
        console.warn(`${response.failed} tab(s) could not be opened.`);
    }
}

browser.menus.onClicked.addListener(async (info, tab) => {
    if (!tab) return;

    try {
        const menuId = String(info.menuItemId);

        if (menuId.startsWith("selected:")) {
            const profile = menuId.substring("selected:".length);
            const tabs = await getSelectedTabs(tab);

            await sendTabs(tabs, profile);
        }

        else if (menuId.startsWith("all:")) {
            const profile = menuId.substring("all:".length);

            const tabs = await browser.tabs.query({
                windowId: tab.windowId
            });

            await sendTabs(tabs, profile);
        }

    } catch (error) {
        console.error("Profile Tab Transfer:", error);
    }
});

browser.runtime.onInstalled.addListener(createMenus);
browser.runtime.onStartup.addListener(createMenus);

createMenus();
