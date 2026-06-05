.pragma library

const workspaceIcons = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
];

function workspaceIcon(index) {
    return index < workspaceIcons.length ? workspaceIcons[index] : "";
}

function includes(array, value) {
    if (!array)
        return false;

    return array.indexOf(value) !== -1;
}

function audioSinkShortName(name) {
    if (!name || name.length === 0)
        return "?";

    return name.charAt(0).toUpperCase();
}

function clock(date) {
    return Qt.formatDateTime(date, "ddd, MMM dd - HH:mm");
}

function relativeTime(date) {
    return Qt.formatDateTime(date, "HH:mm");
}
