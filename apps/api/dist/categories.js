"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCategories = getCategories;
const response_1 = require("./response");
const CATEGORIES = [
    'cleaning',
    'handyman',
    'plumbing',
    'electrical',
    'locks',
    'aircon',
    'furniture_assembly',
];
async function getCategories() {
    return (0, response_1.ok)(CATEGORIES.map((slug, index) => ({
        id: slug,
        slug,
        is_active: true,
        sort_order: index,
    })));
}
//# sourceMappingURL=categories.js.map