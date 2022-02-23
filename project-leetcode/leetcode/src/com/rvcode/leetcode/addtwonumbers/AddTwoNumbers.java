package com.rvcode.leetcode.addtwonumbers;

public class AddTwoNumbers {
    public static void main(String[] args) {

        ListNode one = new ListNode(9);

        ListNode two = new ListNode(1);
        ListNode _2 = new ListNode(9);
        ListNode _3 = new ListNode(9);
        ListNode _4 = new ListNode(9);
        ListNode _5 = new ListNode(9);
        ListNode _6 = new ListNode(9);
        ListNode _7 = new ListNode(9);
        ListNode _8 = new ListNode(9);
        ListNode _9 = new ListNode(9);
        ListNode _10 = new ListNode(9);
        two.next = _2;
        _2.next = _3;
        _3.next = _4;
        _4.next = _5;
        _5.next = _6;
        _6.next = _7;
        _7.next = _8;
        _8.next = _9;
        _9.next = _10;

        ListNode mout = s.addTwoNumbers(one, two);

        while(mout!=null){
            System.out.print(mout.val);
            mout = mout.next;
        }
    }
}

class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        ListNode root = null;
        return root;
    }
}

//Definition for singly-linked list.
class ListNode {
    int val;
    ListNode next;

    ListNode() {
    }

    ListNode(int val) {
        this.val = val;
    }

    ListNode(int val, ListNode next) {
        this.val = val;
        this.next = next;
    }
}
