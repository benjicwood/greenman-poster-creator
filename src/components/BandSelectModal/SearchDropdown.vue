<template>
  <div class="dropdown" v-if="options">
    <div class="dropdown-toggle">
      <input
        ref="inputEl"
        :key="id"
        :name="name"
        v-model="searchFilter"
        :disabled="disabled"
        :placeholder="placeholder"
        autocomplete="off"
        @focus="showOptions"
        @blur="onBlurCommit"
        @keydown="onKeydown"
      />
    </div>

    <transition name="fade">
      <ul class="dropdown-menu" v-show="optionsShown && filteredOptions.length">
        <li
          v-for="(option, index) in filteredOptions"
          :key="index"
          @mousedown.prevent="selectOption(option)"
        >
          <a href="javascript:void(0)">
            {{ optionLabel(option) }}
          </a>
        </li>
      </ul>
    </transition>
  </div>
</template>

<script>
export default {
  name: "SearchDropdown",
  props: {
    name: { type: String, default: "input" },
    options: { type: Array, required: true },
    placeholder: { type: String, default: "Start typing..." },
    disabled: { type: Boolean, default: false },
    maxItem: { type: Number, default: 1200 },
    id: { type: Number, default: 0 },
    modelValue: { type: String, default: "" },
  },

  emits: ["selected", "commit", "filter", "update:modelValue"],

  data() {
    return {
      selected: null,
      optionsShown: false,
      searchFilter: "",
      suppressBlurCommit: false,
    };
  },

  computed: {
    filteredOptions() {
      const out = [];
      const term = (this.searchFilter || "").trim();

      const safeTerm = term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      const regex = new RegExp(safeTerm, "i");

      for (const option of this.options) {
        const label = this.optionLabel(option);
        if (!term || regex.test(label)) {
          out.push(option);
          if (out.length >= this.maxItem) break;
        }
      }

      return out;
    },
  },

  watch: {
    modelValue: {
      immediate: true,
      handler(val) {
        this.searchFilter = val || "";
        if (!val) {
          this.hideOptions();
        }
      },
    },

    searchFilter(val) {
      this.$emit("update:modelValue", val);
      this.$emit("filter", val);
      this.selected = null;

      if (this.disabled) {
        this.hideOptions();
        return;
      }

      const isFocused = document.activeElement === this.$refs.inputEl;
      if (isFocused && val.trim()) {
        this.optionsShown = true;
      } else if (!val.trim()) {
        this.hideOptions();
      }
    },
  },

  methods: {
    focus() {
      this.$refs.inputEl?.focus();
    },

    blur() {
      this.$refs.inputEl?.blur();
    },

    blurWithoutCommit() {
      this.suppressBlurCommit = true;
      this.$refs.inputEl?.blur();

      requestAnimationFrame(() => {
        this.suppressBlurCommit = false;
      });
    },

    optionLabel(option) {
      return (option?.name || option?.id || "-").toString();
    },

    showOptions() {
      if (this.disabled) return;
      if ((this.searchFilter || "").trim()) {
        this.optionsShown = true;
      }
    },

    hideOptions() {
      this.optionsShown = false;
    },

    resetInput({ keepFocus = false } = {}) {
      this.searchFilter = "";
      this.selected = null;
      this.hideOptions();

      this.$emit("update:modelValue", "");

      this.$nextTick(() => {
        if (keepFocus) {
          this.$refs.inputEl?.focus();
        } else {
          this.$refs.inputEl?.blur();
        }
      });
    },

    selectOption(option) {
      this.suppressBlurCommit = true;

      const label = this.optionLabel(option);

      this.$emit("selected", option);
      this.$emit("commit", { type: "option", text: label, option });

      this.resetInput({ keepFocus: true });

      requestAnimationFrame(() => {
        this.suppressBlurCommit = false;
      });
    },

    commitTypedText() {
      const text = (this.searchFilter || "").trim();

      if (!text) {
        this.resetInput({ keepFocus: true });
        this.$emit("commit", { type: "clear", text: "" });
        return;
      }

      const match = this.options.find((o) => {
        const label = this.optionLabel(o).toLowerCase();
        return label === text.toLowerCase();
      });

      if (match) {
        this.$emit("selected", match);
        this.$emit("commit", { type: "option", text, option: match });
      } else {
        this.$emit("commit", { type: "custom", text });
      }

      this.$nextTick(() => {
        this.resetInput({ keepFocus: true });
      });
    },

    onBlurCommit() {
      if (this.suppressBlurCommit) return;
      this.commitTypedText();
    },

    onKeydown(e) {
      if (e.key === "Escape") {
        e.preventDefault();
        this.resetInput();
        return;
      }

      if (e.key === "Enter") {
        e.preventDefault();
        this.commitTypedText();
        return;
      }

      if (e.key === "ArrowDown") {
        if ((this.searchFilter || "").trim()) {
          this.showOptions();
        }
      }
    },
  },
};
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 250ms cubic-bezier(0.25, 0.46, 0.45, 0.94) 0s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.dropdown {
  min-width: 160px;
  position: relative;
  margin: 0;
  display: block;
  width: 100%;
}

.dropdown-toggle input {
  border: none;
  background: #0002;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  padding-left: 0.5rem;
  outline: none;
  transition: 0.2s ease-in;
  color: gray;
  border-radius: 4px;
  height: 1.5rem;
  width: 100%;
  box-sizing: border-box;
  height: 2.5rem;
}

.dropdown-toggle:hover input {
  background: #0004;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 2000;
  width: 100%;
  max-height: 200px;
  overflow-y: auto;
  padding: 0.5rem;
  margin: 0;
  list-style: none;
  font-size: 14px;
  background-color: #fff;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.175);
  box-sizing: border-box;
}

.dropdown-menu > li > a {
  padding: 10px 20px;
  display: block;
  color: #333;
  white-space: nowrap;
  text-decoration: none;
}

.dropdown-menu > li > a:hover {
  background: #efefef;
  color: #409fcb;
  border-radius: 4px;
}

.dropdown-menu > li {
  margin: 0;
}
</style>
