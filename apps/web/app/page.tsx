"use client";

import { Button } from "ui";

import styles from "../styles/index.module.css";

export default function Web() {
  return (
    <div className={styles.container}>
      <h1>Web</h1>
      <Button onClick={() => alert("Pressed!")} >Boop</Button>
    </div>
  );
}
